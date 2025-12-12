import * as XLSX from 'xlsx'
import { ElMessage } from 'element-plus'

/**
 * Excel导出工具
 */

/**
 * 导出Excel文件
 * @param {Array} data - 数据数组
 * @param {Array} columns - 列配置 [{key: 'name', label: '名称'}, ...]
 * @param {String} filename - 文件名
 */
export function exportExcel(data, columns, filename = '导出数据') {
  try {
    // 构建表头
    const headers = columns.map(col => col.label)
    
    // 构建数据行
    const rows = data.map(item => {
      return columns.map(col => {
        const value = item[col.key]
        // 处理嵌套对象
        if (col.formatter && typeof col.formatter === 'function') {
          return col.formatter(value, item)
        }
        return value || ''
      })
    })

    // 创建工作簿
    const wb = XLSX.utils.book_new()
    
    // 创建工作表数据
    const wsData = [headers, ...rows]
    const ws = XLSX.utils.aoa_to_sheet(wsData)

    // 设置列宽
    const colWidths = columns.map(() => ({ wch: 15 }))
    ws['!cols'] = colWidths

    // 添加工作表到工作簿
    XLSX.utils.book_append_sheet(wb, ws, 'Sheet1')

    // 导出文件
    const fileName = `${filename}_${new Date().getTime()}.xlsx`
    XLSX.writeFile(wb, fileName)
    
    ElMessage.success('导出成功')
  } catch (error) {
    console.error('导出失败:', error)
    ElMessage.error('导出失败')
  }
}

