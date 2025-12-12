import request from './index'

/**
 * 字典管理API
 */

/**
 * 字典列表查询
 */
export function getDictList(params) {
  return request({
    url: '/admin/dict/list',
    method: 'get',
    params
  })
}

/**
 * 新增字典
 */
export function saveDict(data) {
  return request({
    url: '/admin/dict/save',
    method: 'post',
    data
  })
}

