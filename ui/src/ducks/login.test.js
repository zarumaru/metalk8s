import { call, put } from 'redux-saga/effects';
import history from '../history';
import {
  authenticate,
  HASH_KEY,
  AUTHENTICATION_FAILED,
  AUTHENTICATION_SUCCESS,
  SET_USER_INFO_LOADED,
  fetchUserInfo,
  authenticateSaltApi,
} from './login';
import * as ApiK8s from '../services/k8s/api';

it('authentication failed', () => {
  const payload = { username: 'admin', password: 'admin' };
  const gen = authenticate({ payload });
  const token = btoa('admin:admin');

  expect(gen.next().value).toEqual(call(ApiK8s.authenticate, token));

  const result = {
    error: {
      response: {
        data: 'Unauthorized',
      },
    },
  };
  expect(gen.next(result).value).toEqual(
    put({
      type: AUTHENTICATION_FAILED,
      payload: 'Unauthorized',
    }),
  );
  expect(gen.next(result).value).toEqual(
    put({
      type: SET_USER_INFO_LOADED,
      payload: true,
    }),
  );
});

it('authentication success', () => {
  const payload = { username: 'admin', password: 'admin' };
  const gen = authenticate({ payload });
  const token = btoa('admin:admin');

  expect(gen.next().value).toEqual(call(ApiK8s.authenticate, token));

  const result = {
    data: {},
  };

  expect(gen.next(result).value.type).toEqual('SELECT');
  expect(gen.next({ url: 'localhost:8080' }).value).toEqual(
    call(ApiK8s.updateApiServerConfig, 'localhost:8080', token),
  );

  expect(gen.next().value).toEqual(
    put({
      type: AUTHENTICATION_SUCCESS,
      payload: {
        username: 'admin',
        password: 'admin',
      },
    }),
  );

  expect(gen.next().value).toEqual(call(authenticateSaltApi, true));

  expect(gen.next(result).value).toEqual(
    put({
      type: SET_USER_INFO_LOADED,
      payload: true,
    }),
  );
});

it('fetchUserInfo success', () => {
  localStorage.setItem(HASH_KEY, 'dGVzdDp0ZXN0');

  const gen = fetchUserInfo();
  expect(gen.next().value.type).toEqual('SELECT');
  expect(gen.next({ url: 'localhost:8080' }).value).toEqual(
    call(ApiK8s.updateApiServerConfig, 'localhost:8080', 'dGVzdDp0ZXN0'),
  );

  const result = {
    data: {},
  };
  expect(gen.next(result).value).toEqual(
    put({
      type: AUTHENTICATION_SUCCESS,
      payload: {
        username: 'test',
        password: 'test',
      },
    }),
  );

  expect(gen.next().value).toEqual(call(authenticateSaltApi));

  expect(gen.next(result).value).toEqual(
    put({
      type: SET_USER_INFO_LOADED,
      payload: true,
    }),
  );
  localStorage.removeItem(HASH_KEY);
});

it('fetchUserInfo failed', () => {
  localStorage.removeItem(HASH_KEY);

  const gen = fetchUserInfo();
  expect(gen.next().value).toEqual(call(history.push, '/login'));

  expect(gen.next().value).toEqual(
    put({
      type: SET_USER_INFO_LOADED,
      payload: true,
    }),
  );
});
