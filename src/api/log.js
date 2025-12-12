import request from './index'

/**
 * 日志管理API
 */

/**
 * 登录日志列表查询
 */
export function getLoginLogList(params) {
  return request({
    url: '/admin/log/loginList',
    method: 'get',
    params
  })
}
