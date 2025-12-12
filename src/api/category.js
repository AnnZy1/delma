import request from './index'

/**
 * 分类管理API
 */

/**
 * 分类列表查询
 */
export function getCategoryList(params) {
  return request({
    url: '/admin/category/list',
    method: 'get',
    params
  })
}

/**
 * 新增分类
 */
export function saveCategory(data) {
  return request({
    url: '/admin/category/save',
    method: 'post',
    data
  })
}

/**
 * 修改分类
 */
export function updateCategory(data) {
  return request({
    url: '/admin/category/update',
    method: 'put',
    data
  })
}

/**
 * 删除分类
 */
export function deleteCategory(id) {
  return request({
    url: `/admin/category/delete/${id}`,
    method: 'delete'
  })
}

/**
 * 批量操作
 */
export function batchCategory(data) {
  return request({
    url: '/admin/category/batch',
    method: 'post',
    data
  })
}

/**
 * 拖拽排序
 */
export function sortCategory(data) {
  return request({
    url: '/admin/category/sort',
    method: 'post',
    data
  })
}

