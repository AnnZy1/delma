import request from './index'

/**
 * 数据统计API
 */

/**
 * 营业数据统计
 */
export function getBusinessStat(params) {
  return request({
    url: '/admin/stat/business',
    method: 'get',
    params
  })
}

/**
 * 销量排行
 */
export function getSalesTop(params) {
  return request({
    url: '/admin/stat/salesTop',
    method: 'get',
    params
  })
}

/**
 * 订单分析
 */
export function getOrderAnalysis(params) {
  return request({
    url: '/admin/stat/orderAnalysis',
    method: 'get',
    params
  })
}

