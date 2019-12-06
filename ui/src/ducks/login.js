import { call, takeEvery, put, select } from 'redux-saga/effects';
import * as ApiK8s from '../services/k8s/api';
import * as ApiSalt from '../services/salt/api';

import history from '../history';
import { connectSaltApiAction } from './app/salt';

// Actions
const AUTHENTICATE = 'AUTHENTICATE';
export const AUTHENTICATION_SUCCESS = 'AUTHENTICATION_SUCCESS';
export const AUTHENTICATION_FAILED = 'AUTHENTICATION_FAILED';
export const SALT_AUTHENTICATION_SUCCESS = 'SALT_AUTHENTICATION_SUCCESS';
export const SALT_AUTHENTICATION_FAILED = 'SALT_AUTHENTICATION_FAILED';
const LOGOUT = 'LOGOUT';
export const FETCH_USER_INFO = 'FETCH_USER_INFO';
export const SET_USER_INFO_LOADED = 'SET_USER_INFO_LOADED';

export const HASH_KEY = 'token';

// Reducer
const defaultState = {
  user: null,
  error: null,
  isUserInfoLoaded: false,
};

export default function reducer(state = defaultState, action = {}) {
  switch (action.type) {
    case AUTHENTICATION_SUCCESS:
      return {
        ...state,
        user: action.payload,
      };
    case SALT_AUTHENTICATION_SUCCESS:
      return {
        ...state,
        salt: action.payload,
      };
    case AUTHENTICATION_FAILED:
      return {
        ...state,
        errors: { authentication: action.payload.message },
      };
    case SET_USER_INFO_LOADED:
      return {
        ...state,
        isUserInfoLoaded: action.payload,
      };

    default:
      return state;
  }
}

// Action Creators
export const authenticateAction = payload => {
  return { type: AUTHENTICATE, payload };
};

export const logoutAction = () => {
  return { type: LOGOUT };
};

export const fetchUserInfoAction = () => {
  return { type: FETCH_USER_INFO };
};

export const setUserInfoLoadedAction = payload => {
  return { type: SET_USER_INFO_LOADED, payload };
};

export const setAuthenticationSuccessAction = payload => {
  return {
    type: AUTHENTICATION_SUCCESS,
    payload,
  };
};

export const setSaltAuthenticationSuccessAction = payload => {
  return {
    type: SALT_AUTHENTICATION_SUCCESS,
    payload,
  };
};

// Sagas
export function* authenticate({ payload }) {
  const { username, password } = payload;
  const token = btoa(username + ':' + password); //base64Encode

  const result = yield call(ApiK8s.authenticate, token);
  if (result.error) {
    yield put({
      type: AUTHENTICATION_FAILED,
      payload: result.error.response.data,
    });
  } else {
    const api_server = yield select(state => state.config.api);
    yield call(ApiK8s.updateApiServerConfig, api_server.url, token);
    localStorage.setItem(HASH_KEY, token);
    yield put(
      setAuthenticationSuccessAction({
        username,
        password,
        token,
      }),
    );
    yield call(authenticateSaltApi, true);
  }
  yield put(setUserInfoLoadedAction(true));
}

export function* authenticateSaltApi(redirect) {
  const api = yield select(state => state.config.api);
  const user = yield select(state => state.login.user);
  const result = yield call(ApiSalt.authenticate, user);
  if (!result.error) {
    yield call(ApiSalt.getClient().setHeaders, {
      'X-Auth-Token': result.return[0].token,
    });
    yield put(setSaltAuthenticationSuccessAction(result));
    yield put(
      connectSaltApiAction({
        url: api.url_salt,
        token: result.return[0].token,
      }),
    );
    if (redirect) {
      yield call(history.push, '/');
    }
  } else {
    yield call(logout);
  }
}

export function* logout() {
  yield call(() => localStorage.removeItem(HASH_KEY));
  yield call(history.push, '/login');
}

export function* fetchUserInfo() {
  const token = localStorage.getItem(HASH_KEY);
  if (token) {
    const api_server = yield select(state => state.config.api);
    yield call(ApiK8s.updateApiServerConfig, api_server.url, token);

    const decryptedToken = atob(token);
    const splits = decryptedToken.split(':');
    const username = splits.length > 1 ? splits[0] : null;
    const password = splits.length > 1 ? splits[1] : null;
    yield put(
      setAuthenticationSuccessAction({
        username,
        password,
        token,
      }),
    );
    yield call(authenticateSaltApi);
  } else {
    yield call(history.push, '/login');
  }
  yield put(setUserInfoLoadedAction(true));
}

export function* authenticateSaga() {
  yield takeEvery(AUTHENTICATE, authenticate);
  yield takeEvery(LOGOUT, logout);
  yield takeEvery(FETCH_USER_INFO, fetchUserInfo);
}
