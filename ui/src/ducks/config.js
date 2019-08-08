import { call, put, takeEvery, select } from 'redux-saga/effects';
import { mergeTheme } from '@scality/core-ui/dist/utils';
import * as defaultTheme from '@scality/core-ui/dist/style/theme';
import * as Api from '../services/api';
import * as ApiK8s from '../services/k8s/api';
import * as ApiSalt from '../services/salt/api';
import * as ApiPrometheus from '../services/prometheus/api';
import { fetchClusterVersion } from './app/nodes';
import { fetchUserInfo } from './login';
import { EN_LANG, FR_LANG, LANGUAGE } from '../constants';

// Actions
export const SET_LANG = 'SET_LANG';
export const SET_THEME = 'SET_THEME';
export const SET_SOLUTIONS = 'SET_SOLUTIONS';
export const SET_SERVICES = 'SET_SERVICES';

const FETCH_THEME = 'FETCH_THEME';
const FETCH_CONFIG = 'FETCH_CONFIG';
export const SET_API_CONFIG = 'SET_API_CONFIG';
const SET_INITIAL_LANGUAGE = 'SET_INITIAL_LANGUAGE';
const UPDATE_LANGUAGE = 'UPDATE_LANGUAGE';

const SOLUTION_CONFIGMAP_NAME = 'metalk8s-solutions';

const APP_K8S_COMPONENT_LABEL = 'app.kubernetes.io/component';
const APP_K8S_PART_OF_SOLUTION_LABEL = 'app.kubernetes.io/part-of';
const APP_K8S_VERSION_LABEL = 'app.kubernetes.io/version';

// Reducer
const defaultState = {
  language: EN_LANG,
  theme: {},
  api: null,
  solutions: [],
  services: []
};

export default function reducer(state = defaultState, action = {}) {
  switch (action.type) {
    case SET_LANG:
      return { ...state, language: action.payload };
    case SET_THEME:
      return { ...state, theme: action.payload };
    case SET_API_CONFIG:
      return { ...state, api: action.payload };
    case SET_SOLUTIONS:
      return { ...state, solutions: action.payload };
    case SET_SERVICES:
      return { ...state, services: action.payload };
    default:
      return state;
  }
}

// Action Creators
export function setLanguageAction(newLang) {
  return { type: SET_LANG, payload: newLang };
}

export function setThemeAction(theme) {
  return { type: SET_THEME, payload: theme };
}

export function setSolutionsAction(solutions) {
  return { type: SET_SOLUTIONS, payload: solutions };
}

export function setServicesAction(services) {
  return { type: SET_SERVICES, payload: services };
}

export function fetchThemeAction() {
  return { type: FETCH_THEME };
}

export function fetchConfigAction() {
  return { type: FETCH_CONFIG };
}

export function setApiConfigAction(conf) {
  return { type: SET_API_CONFIG, payload: conf };
}

export function setInitialLanguageAction() {
  return { type: SET_INITIAL_LANGUAGE };
}

export function updateLanguageAction(language) {
  return { type: UPDATE_LANGUAGE, payload: language };
}

// Sagas
export function* fetchTheme() {
  const result = yield call(Api.fetchTheme);
  if (!result.error) {
    result.brand = mergeTheme(result, defaultTheme);
    yield put(setThemeAction(result));
  }
}

export function* fetchConfig() {
  yield call(Api.initialize, process.env.PUBLIC_URL);
  const result = yield call(Api.fetchConfig);
  if (!result.error) {
    yield call(fetchTheme);
    yield put(setApiConfigAction(result));
    yield call(ApiK8s.initialize, result.url);
    yield call(ApiSalt.initialize, result.url_salt);
    yield call(ApiPrometheus.initialize, result.url_prometheus);
    yield call(fetchUserInfo);
    yield call(fetchClusterVersion);
    yield call(fetchServices);
    yield call(fetchSolutions);
  }
}

export function* setInitialLanguage() {
  const languageLocalStorage = localStorage.getItem(LANGUAGE);
  if (languageLocalStorage) {
    languageLocalStorage === FR_LANG
      ? yield put(setLanguageAction(FR_LANG))
      : yield put(setLanguageAction(EN_LANG));
  } else {
    yield put(
      setLanguageAction(navigator.language.startsWith('fr') ? FR_LANG : EN_LANG)
    );
  }
}

export function* updateLanguage(action) {
  yield put(setLanguageAction(action.payload));
  const language = yield select(state => state.config.language);
  localStorage.setItem(LANGUAGE, language);
}

export function* fetchServices() {
  const result = yield call(ApiK8s.getServiceForAllNamespaces);
  if (!result.error) {
    yield put(setServicesAction(result.body.items));
  }
}

export function* fetchSolutions() {
  const services = yield select(state => state.config.services);
  if (services) {
    const result = yield call(ApiK8s.getConfigMapForAllNamespaces);
    if (!result.error) {
      const solutionsConfigMap = result.body.items.find(
        item => item.metadata.name === SOLUTION_CONFIGMAP_NAME
      );
      if (solutionsConfigMap && solutionsConfigMap.data) {
        const solutions = Object.keys(solutionsConfigMap.data).map(key => {
          return {
            name: key,
            ...JSON.parse(solutionsConfigMap.data[key])
          };
        });
        solutions.forEach(sol => {
          sol.versions.forEach(version => {
            if (version.deployed) {
              version.ui_url =
                services.find(
                  service =>
                    service.metadata.labels &&
                    service.metadata.labels[APP_K8S_COMPONENT_LABEL] === 'ui' &&
                    service.metadata.labels[APP_K8S_PART_OF_SOLUTION_LABEL] ===
                      sol.name &&
                    service.metadata.labels[APP_K8S_VERSION_LABEL] ===
                      version.version
                ) || '';
            }
          });
        });
        yield put(setSolutionsAction(solutions));
      }
    }
  }
}

export function* configSaga() {
  yield takeEvery(FETCH_THEME, fetchTheme);
  yield takeEvery(FETCH_CONFIG, fetchConfig);
  yield takeEvery(SET_INITIAL_LANGUAGE, setInitialLanguage);
  yield takeEvery(UPDATE_LANGUAGE, updateLanguage);
}
