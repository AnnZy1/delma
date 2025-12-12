import request from './index'

/**
 * 角色管理API
 */

/**
 * 角色列表查询
 */
export function getRoleList(params) {
  return request({
    url: '/admin/role/list',
    method: 'get',
    params
  })
}

/**
 * 新增角色
 */
export function saveRole(data) {
  return request({
    url: '/admin/role/save',
    method: 'post',
    data
  })
}

/**
 * 修改角色
 */
export function updateRole(data) {
  return request({
    url: '/admin/role/update',
    method: 'put',
    data
  })
}

/**
 * 删除角色
 */
export function deleteRole(id) {
  return request({
    url: `/admin/role/delete/${id}`,
    method: 'delete'
  })
}

