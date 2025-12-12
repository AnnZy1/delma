/**
 * 前端常量定义
 */

// 订单状态
export const ORDER_STATUS = {
  PENDING_PAYMENT: 1, // 待付款
  PENDING_ACCEPT: 2, // 待接单
  ACCEPTED: 3, // 已接单
  DELIVERING: 4, // 配送中
  COMPLETED: 5, // 已完成
  CANCELLED: 6, // 已取消
  REFUNDED: 7 // 已退款
}

// 订单状态标签
export const ORDER_STATUS_LABELS = {
  [ORDER_STATUS.PENDING_PAYMENT]: '待付款',
  [ORDER_STATUS.PENDING_ACCEPT]: '待接单',
  [ORDER_STATUS.ACCEPTED]: '已接单',
  [ORDER_STATUS.DELIVERING]: '配送中',
  [ORDER_STATUS.COMPLETED]: '已完成',
  [ORDER_STATUS.CANCELLED]: '已取消',
  [ORDER_STATUS.REFUNDED]: '已退款'
}

// 订单状态颜色
export const ORDER_STATUS_COLORS = {
  [ORDER_STATUS.PENDING_PAYMENT]: 'warning',
  [ORDER_STATUS.PENDING_ACCEPT]: 'info',
  [ORDER_STATUS.ACCEPTED]: 'primary',
  [ORDER_STATUS.DELIVERING]: 'success',
  [ORDER_STATUS.COMPLETED]: 'success',
  [ORDER_STATUS.CANCELLED]: 'danger',
  [ORDER_STATUS.REFUNDED]: 'info'
}

// 员工状态
export const EMPLOYEE_STATUS = {
  NORMAL: 1, // 正常
  LOCKED: 0 // 锁定
}

// 员工状态标签
export const EMPLOYEE_STATUS_LABELS = {
  [EMPLOYEE_STATUS.NORMAL]: '正常',
  [EMPLOYEE_STATUS.LOCKED]: '锁定'
}

// 分类类型
export const CATEGORY_TYPE = {
  DISH: 1, // 菜品
  SETMEAL: 2 // 套餐
}

// 分类类型标签
export const CATEGORY_TYPE_LABELS = {
  [CATEGORY_TYPE.DISH]: '菜品',
  [CATEGORY_TYPE.SETMEAL]: '套餐'
}

// 商品状态
export const PRODUCT_STATUS = {
  ON_SALE: 1, // 起售
  OFF_SALE: 0 // 停售
}

// 商品状态标签
export const PRODUCT_STATUS_LABELS = {
  [PRODUCT_STATUS.ON_SALE]: '起售',
  [PRODUCT_STATUS.OFF_SALE]: '停售'
}

// 性别
export const GENDER = {
  MALE: '男',
  FEMALE: '女',
  UNKNOWN: '未知'
}

// 批量操作类型
export const BATCH_OPERATION = {
  LOCK: 'lock', // 锁定
  UNLOCK: 'unlock', // 启用
  DELETE: 'delete', // 删除
  ON_SALE: 'onSale', // 起售
  OFF_SALE: 'offSale' // 停售
}

// 批量操作标签
export const BATCH_OPERATION_LABELS = {
  [BATCH_OPERATION.LOCK]: '锁定',
  [BATCH_OPERATION.UNLOCK]: '启用',
  [BATCH_OPERATION.DELETE]: '删除',
  [BATCH_OPERATION.ON_SALE]: '起售',
  [BATCH_OPERATION.OFF_SALE]: '停售'
}

// 统计时间类型
export const STAT_TIME_TYPE = {
  TODAY: 'today',
  WEEK: 'week',
  MONTH: 'month',
  CUSTOM: 'custom'
}

// 统计时间类型标签
export const STAT_TIME_TYPE_LABELS = {
  [STAT_TIME_TYPE.TODAY]: '今日',
  [STAT_TIME_TYPE.WEEK]: '本周',
  [STAT_TIME_TYPE.MONTH]: '本月',
  [STAT_TIME_TYPE.CUSTOM]: '自定义'
}

// 销量排行类型
export const SALES_TOP_TYPE = {
  DISH: 'dish',
  SETMEAL: 'setmeal'
}

// 销量排行类型标签
export const SALES_TOP_TYPE_LABELS = {
  [SALES_TOP_TYPE.DISH]: '菜品',
  [SALES_TOP_TYPE.SETMEAL]: '套餐'
}

