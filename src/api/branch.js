import request from './index'

/**
 * 分店管理API
 */

/**
 * 分店列表查询
 */
export function getBranchList(params) {
  return request({
    url: '/admin/branch/list',
    method: 'get',
    params
  })
}

/**
 * 新增分店
 */
export function saveBranch(data) {
  return request({
    url: '/admin/branch/save',
    method: 'post',
    data
  })
}

/**
 * 修改分店
 */
export function updateBranch(data) {
  return request({
    url: '/admin/branch/update',
    method: 'put',
    data
  })
}

/**
 * 删除分店
 */
export function deleteBranch(id) {
  return request({
    url: `/admin/branch/delete/${id}`,
    method: 'delete'
  })
}

