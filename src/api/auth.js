import request from './index'

/**
 * 认证相关API
 */

/**
 * 员工登录
 */
export function login(data) {
  return request({
    url: '/admin/auth/login',
    method: 'post',
    data
  })
}

/**
 * 员工退出
 */
export function logout() {
  return request({
    url: '/admin/auth/logout',
    method: 'post'
  })
}

/**
 * 账号解锁
 */
export function unlock(data) {
  return request({
    url: '/admin/auth/unlock',
    method: 'post',
    data
  })
}

