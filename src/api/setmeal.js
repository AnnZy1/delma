import request from './index'

/**
 * 套餐管理API
 */

/**
 * 套餐列表查询
 */
export function getSetmealList(params) {
  return request({
    url: '/admin/setmeal/list',
    method: 'get',
    params
  })
}

/**
 * 新增套餐
 */
export function saveSetmeal(data) {
  return request({
    url: '/admin/setmeal/save',
    method: 'post',
    data
  })
}

/**
 * 修改套餐
 */
export function updateSetmeal(data) {
  return request({
    url: '/admin/setmeal/update',
    method: 'put',
    data
  })
}

/**
 * 删除套餐
 */
export function deleteSetmeal(id) {
  return request({
    url: `/admin/setmeal/delete/${id}`,
    method: 'delete'
  })
}

/**
 * 批量操作
 */
export function batchSetmeal(data) {
  return request({
    url: '/admin/setmeal/batch',
    method: 'post',
    data
  })
}

/**
 * 导出套餐
 */
export function exportSetmeal(params) {
  return request({
    url: '/admin/setmeal/export',
    method: 'get',
    params,
    responseType: 'blob'
  })
}

