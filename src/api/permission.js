import request from './index'

/**
 * 权限管理API
 */

/**
 * 获取权限树
 */
export function getPermissionTree() {
  return request({
    url: '/admin/permission/tree',
    method: 'get'
  })
}
