import dayjs from 'dayjs'

/**
 * 格式化工具函数
 */

/**
 * 格式化日期时间
 */
export function formatDateTime(date, format = 'YYYY-MM-DD HH:mm:ss') {
  if (!date) return '-'
  return dayjs(date).format(format)
}

/**
 * 格式化日期
 */
export function formatDate(date, format = 'YYYY-MM-DD') {
  if (!date) return '-'
  return dayjs(date).format(format)
}

/**
 * 格式化金额
 */
export function formatMoney(amount) {
  if (amount === null || amount === undefined) return '0.00'
  return Number(amount).toFixed(2)
}

/**
 * 格式化手机号（脱敏）
 */
export function formatPhone(phone) {
  if (!phone) return '-'
  return phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2')
}

/**
 * 格式化身份证号（脱敏）
 */
export function formatIdNumber(idNumber) {
  if (!idNumber) return '-'
  return idNumber.replace(/(\d{6})\d{8}(\d{4})/, '$1********$2')
}

/**
 * 格式化订单号
 */
export function formatOrderNumber(number) {
  if (!number) return '-'
  return number
}

