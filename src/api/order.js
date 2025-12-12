import request from './index'

/**
 * 订单管理API
 */

/**
 * 订单列表查询
 */
export function getOrderList(params) {
  return request({
    url: '/admin/order/list',
    method: 'get',
    params
  })
}

/**
 * 订单详情
 */
export function getOrderDetail(id) {
  return request({
    url: '/admin/order/detail',
    method: 'get',
    params: { id }
  })
}

/**
 * 修改订单状态
 */
export function updateOrderStatus(data) {
  return request({
    url: '/admin/order/updateStatus',
    method: 'put',
    data
  })
}

export function acceptOrder(id) {
  return updateOrderStatus({ id, status: 3 })
}

/**
 * 派送订单
 */
export function deliveryOrder(id) {
  return updateOrderStatus({ id, status: 4 })
}

/**
 * 完成订单
 */
export function completeOrder(id) {
  return updateOrderStatus({ id, status: 5 })
}

/**
 * 取消订单
 */
export function cancelOrder(data) {
  return request({
    url: '/admin/order/cancel',
    method: 'post',
    data
  })
}

/**
 * 导出订单
 */
export function exportOrder(params) {
  return request({
    url: '/admin/order/export',
    method: 'get',
    params,
    responseType: 'blob'
  })
}
