<template>
  <div class="stat-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span class="title">营业数据统计</span>
          <div class="filter-group">
            <el-radio-group v-model="timeType" @change="handleTimeTypeChange">
              <el-radio-button label="today">今日</el-radio-button>
              <el-radio-button label="week">本周</el-radio-button>
              <el-radio-button label="month">本月</el-radio-button>
              <el-radio-button label="custom">自定义</el-radio-button>
            </el-radio-group>
            <el-date-picker
              v-if="timeType === 'custom'"
              v-model="dateRange"
              type="datetimerange"
              range-separator="至"
              start-placeholder="开始时间"
              end-placeholder="结束时间"
              value-format="YYYY-MM-DD HH:mm:ss"
              style="margin-left: 10px; width: 360px"
              @change="handleDateChange"
            />
          </div>
        </div>
      </template>

      <!-- 统计卡片 -->
      <el-row :gutter="20" class="stat-cards">
        <el-col :span="6" v-for="(item, index) in statItems" :key="index">
          <el-card class="stat-card" shadow="hover">
            <div class="stat-item">
              <div class="stat-icon" :style="{ background: item.color }">
                <el-icon><component :is="item.icon" /></el-icon>
              </div>
              <div class="stat-content">
                <div class="stat-value">{{ item.value }}</div>
                <div class="stat-label">{{ item.label }}</div>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>

      <!-- 图表区域 -->
      <el-row :gutter="20" class="charts-container">
        <!-- 销量排行 -->
        <el-col :span="12">
          <el-card shadow="hover" class="chart-card">
            <template #header>
              <div class="card-header">
                <span class="title">销量排行</span>
                <el-tabs v-model="salesTopType" @tab-change="handleSalesTopChange" class="chart-tabs">
                  <el-tab-pane label="菜品" name="dish" />
                  <el-tab-pane label="套餐" name="setmeal" />
                </el-tabs>
              </div>
            </template>
            <el-table 
              :data="salesTopData" 
              style="width: 100%" 
              height="350"
              :header-cell-style="{ background: '#f5f7fa' }"
            >
              <el-table-column type="index" label="排名" width="80" align="center">
                <template #default="{ $index }">
                  <span :class="['rank-badge', $index < 3 ? 'top-' + ($index + 1) : '']">{{ $index + 1 }}</span>
                </template>
              </el-table-column>
              <el-table-column prop="name" label="名称" show-overflow-tooltip />
              <el-table-column prop="sales" label="销量" width="100" align="center" sortable />
              <el-table-column prop="amount" label="销售额" width="120" align="right">
                <template #default="{ row }">
                  <span class="amount">¥{{ row.amount }}</span>
                </template>
              </el-table-column>
            </el-table>
          </el-card>
        </el-col>

        <!-- 订单分析 -->
        <el-col :span="12">
          <el-card shadow="hover" class="chart-card">
            <template #header>
              <div class="card-header">
                <span class="title">订单分析</span>
              </div>
            </template>
            <div ref="chartRef" class="chart-box"></div>
          </el-card>
        </el-col>
      </el-row>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, onUnmounted, nextTick } from 'vue'
import { getBusinessStat, getSalesTop, getOrderAnalysis } from '@/api/stat'
import * as echarts from 'echarts'
import { Money, Document, ShoppingBag, Wallet } from '@element-plus/icons-vue'

const timeType = ref('today')
const dateRange = ref(null)
const salesTopType = ref('dish')
const chartRef = ref(null)
let orderAnalysisChart = null

const statData = reactive({
  totalAmount: '0.00',
  orderCount: 0,
  avgAmount: '0.00',
  refundAmount: '0.00'
})

const statItems = computed(() => [
  { 
    label: '总营业额', 
    value: `¥${statData.totalAmount || '0.00'}`, 
    icon: 'Money', 
    color: 'linear-gradient(135deg, #409eff, #36cfc9)' 
  },
  { 
    label: '订单总数', 
    value: statData.orderCount || 0, 
    icon: 'Document', 
    color: 'linear-gradient(135deg, #67c23a, #95d475)' 
  },
  { 
    label: '客单价', 
    value: `¥${statData.avgAmount || '0.00'}`, 
    icon: 'ShoppingBag', 
    color: 'linear-gradient(135deg, #e6a23c, #f3d19e)' 
  },
  { 
    label: '退款金额', 
    value: `¥${statData.refundAmount || '0.00'}`, 
    icon: 'Wallet', 
    color: 'linear-gradient(135deg, #f56c6c, #ff9090)' 
  }
])

const salesTopData = ref([])

const handleTimeTypeChange = () => {
  dateRange.value = null
  loadAllData()
}

const handleDateChange = (dates) => {
  if (dates && dates.length === 2) {
    loadAllData()
  }
}

const handleSalesTopChange = () => {
  loadSalesTop()
}

const getParams = () => {
  // 确保后端接收的参数格式正确
  // AdminStatController 的 getBusinessStat 需要 StatBusinessDTO (beginTime, endTime)
  // 如果 timeType 不是 custom，也需要计算出 beginTime 和 endTime
  const params = {}
  
  if (timeType.value === 'custom' && dateRange.value && dateRange.value.length === 2) {
    params.beginTime = dateRange.value[0]
    params.endTime = dateRange.value[1]
  } else {
    const { begin, end } = calculateTimeRange(timeType.value)
    if (begin && end) {
      params.beginTime = begin
      params.endTime = end
    }
  }
  // 业务统计与订单分析需要 type（today/week/month/custom）
  params.type = timeType.value
  return params
}

const calculateTimeRange = (type) => {
  const now = new Date()
  let begin = '', end = ''
  
  if (type === 'today') {
    const today = formatDate(now)
    begin = `${today} 00:00:00`
    end = `${today} 23:59:59`
  } else if (type === 'week') {
    const day = now.getDay() || 7
    const monday = new Date(now)
    monday.setDate(now.getDate() - day + 1)
    begin = `${formatDate(monday)} 00:00:00`
    end = `${formatDate(now)} 23:59:59`
  } else if (type === 'month') {
    begin = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-01 00:00:00`
    end = `${formatDate(now)} 23:59:59`
  }
  
  return { begin, end }
}

const formatDate = (date) => {
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
}

const loadStatData = async () => {
  try {
    const res = await getBusinessStat(getParams())
    if (res.code === 200) {
      Object.assign(statData, res.data)
    }
  } catch (error) {
    console.error('加载统计数据失败:', error)
  }
}

const loadSalesTop = async () => {
  try {
    // 销量排行只需要 beginTime 和 endTime
    const params = getParams()
    // 后端接口需要 type (dish/setmeal)，而不是 timeType
    params.type = salesTopType.value
    
    const res = await getSalesTop(params)
    if (res.code === 200) {
      salesTopData.value = res.data || []
    }
  } catch (error) {
    console.error('加载销量排行失败:', error)
  }
}

const loadOrderAnalysis = async () => {
  try {
    const res = await getOrderAnalysis(getParams())
    if (res.code === 200) {
      renderChart(res.data)
    }
  } catch (error) {
    console.error('加载订单分析失败:', error)
  }
}

const loadAllData = () => {
  loadStatData()
  loadSalesTop()
  loadOrderAnalysis()
}

const renderChart = (data) => {
  if (!chartRef.value) return
  
  if (!orderAnalysisChart) {
    orderAnalysisChart = echarts.init(chartRef.value)
  }
  
  const option = {
    tooltip: {
      trigger: 'item',
      formatter: '{a} <br/>{b} : {c} ({d}%)'
    },
    legend: {
      orient: 'vertical',
      right: 10,
      top: 'center',
      textStyle: {
        color: '#666'
      }
    },
    series: [
      {
        name: '订单分布',
        type: 'pie',
        radius: ['40%', '70%'],
        center: ['40%', '50%'],
        avoidLabelOverlap: false,
        itemStyle: {
          borderRadius: 10,
          borderColor: '#fff',
          borderWidth: 2
        },
        label: {
          show: false,
          position: 'center'
        },
        emphasis: {
          label: {
            show: true,
            fontSize: 20,
            fontWeight: 'bold'
          }
        },
        labelLine: {
          show: false
        },
        data: data || []
      }
    ]
  }
  
  orderAnalysisChart.setOption(option)
}

const handleResize = () => {
  orderAnalysisChart?.resize()
}

onMounted(() => {
  loadAllData()
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
  orderAnalysisChart?.dispose()
})
</script>

<style lang="scss" scoped>
@import '@/assets/styles/variables.scss';

.stat-container {
  padding: 20px;

  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    
    .title {
      font-size: 18px;
      font-weight: bold;
      color: $text-primary;
    }
    
    .filter-group {
      display: flex;
      align-items: center;
    }
  }

  .stat-cards {
    margin-bottom: 20px;
    
    .stat-card {
      transition: all 0.3s;
      
      &:hover {
        transform: translateY(-5px);
        box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
      }

      .stat-item {
        display: flex;
        align-items: center;
        padding: 10px 0;

        .stat-icon {
          width: 64px;
          height: 64px;
          border-radius: 16px;
          display: flex;
          align-items: center;
          justify-content: center;
          color: #fff;
          font-size: 32px;
          margin-right: 20px;
          box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
        }

        .stat-content {
          flex: 1;

          .stat-value {
            font-size: 28px;
            font-weight: bold;
            color: $text-primary;
            margin-bottom: 5px;
            font-family: 'DIN Alternate', 'Helvetica Neue', Helvetica, Arial, sans-serif;
          }

          .stat-label {
            font-size: 14px;
            color: $text-secondary;
          }
        }
      }
    }
  }

  .charts-container {
    .chart-card {
      height: 100%;
      
      .chart-box {
        width: 100%;
        height: 350px;
      }
      
      .rank-badge {
        display: inline-block;
        width: 24px;
        height: 24px;
        line-height: 24px;
        text-align: center;
        border-radius: 50%;
        background-color: #f0f2f5;
        color: #606266;
        font-weight: bold;
        font-size: 12px;
        
        &.top-1 {
          background-color: #f56c6c;
          color: #fff;
        }
        
        &.top-2 {
          background-color: #e6a23c;
          color: #fff;
        }
        
        &.top-3 {
          background-color: #409eff;
          color: #fff;
        }
      }
      
      .amount {
        color: #f56c6c;
        font-weight: bold;
      }
    }
  }
}

/* 覆盖 Element Plus 样式 */
:deep(.el-card__header) {
  padding: 15px 20px;
  border-bottom: 1px solid #f0f2f5;
}
</style>
