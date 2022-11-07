import NProgress from 'nprogress';
import Vue from 'vue';
import VueRouter from 'vue-router';
import { default as authStore } from '@/store/modules/auth';

Vue.use(VueRouter);

let isFirstTransition = true;

/**
 * Constructs and returns a Vue Router object
 * @param {string} [basePath='/'] the base server path
 * @returns {object} a Vue Router object
 */
export default function getRouter(basePath = '/') {
  const router = new VueRouter({
    base: basePath,
    mode: 'history',
    routes: [
      {
        path: '/',
        redirect: { name: 'Home' },
      },
      {
        path: '/',
        name: 'Home',
        component: () =>
          import(/* webpackChunkName: "home" */ '@/views/Home.vue'),
        meta: {
          hasLogin: true,
        },
      },
      {
        path: '/secure',
        name: 'Secure',
        component: () =>
          import(/* webpackChunkName: "secure" */ '@/views/Secure.vue'),
        meta: {
          hasLogin: true,
          requiresAuth: true,
        },
      },
      {
        path: '/404',
        alias: '*',
        name: 'NotFound',
        component: () =>
          import(/* webpackChunkName: "not-found" */ '@/views/NotFound.vue'),
        meta: {
          hasLogin: true,
        },
      },
    ],
  });

  router.beforeEach((to, _from, next) => {
    NProgress.start();
    if (
      to.matched.some((route) => route.meta.requiresAuth) &&
      router.app.$keycloak &&
      router.app.$keycloak.ready &&
      !router.app.$keycloak.authenticated
    ) {
      const redirect = location.origin + basePath + to.path + location.search;
      const loginUrl = router.app.$keycloak.createLoginUrl({
        redirectUri: redirect,
      });
      window.location.replace(
        loginUrl + '&pres_req_conf_id=' + authStore.presReqConfId
      );
    }
    if (
      authStore.tokenParsed &&
      authStore.tokenParsed.pres_req_conf_id &&
      authStore.tokenParsed.pres_req_conf_id != authStore.presReqConfId
    ) {
      // console.log('PRES_REQ_CONF_ID mismatch');
      // if satisified request was NOT the configured request, login is invalid
      const redirect = location.origin + basePath + to.path + location.search;
      const loginUrl = router.app.$keycloak.createLoginUrl({
        redirectUri: redirect,
      });
      window.location.replace(
        loginUrl +
          '&pres_req_conf_id=' +
          authStore.presReqConfId +
          '&reason=invalid'
      );
    } else {
      document.title = to.meta.title
        ? to.meta.title
        : process.env.VUE_APP_TITLE;
      if (to.query.r && isFirstTransition) {
        router.replace({
          path: to.query.r.replace(basePath, ''),
          query: (({ r, ...q }) => q)(to.query), // eslint-disable-line no-unused-vars
        });
      }
      next();
    }
  });

  router.afterEach(() => {
    isFirstTransition = false;
    NProgress.done();
  });

  return router;
}
