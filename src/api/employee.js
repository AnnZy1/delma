import request from './index'

/**
 * 员工管理API
 */

/**
 * 员工列表查询
 */
export function getEmployeeList(params) {
  return request({
    url: '/admin/employee/list',
    method: 'get',
    params
  })
}

/**
 * 新增员工
 */
export function saveEmployee(data) {
  return request({
    url: '/admin/employee/save',
    method: 'post',
    data
  })
}

/**
 * 修改员工
 */
export function updateEmployee(data) {
  return request({
    url: '/admin/employee/update',
    method: 'put',
    data
  })
}

/**
 * 密码重置
 */
export function resetPassword(data) {
  return request({
    url: '/admin/employee/resetPwd',
    method: 'post',
    data
  })
}

/**
 * 批量操作
 */
export function batchEmployee(data) {
  return request({
    url: '/admin/employee/batch',
    method: 'post',
    data
  })
}

