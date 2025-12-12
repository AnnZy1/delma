<template>
  <div class="app-container">
    <div class="search-container">
      <el-form :model="queryParams" :inline="true" class="search-form">
        <el-form-item label="订单号">
          <el-input v-model="queryParams.number" placeholder="请输入订单号" clearable @keyup.enter="handleQuery" />
        </el-form-item>
        <el-form-item label="收货人">
          <el-input v-model="queryParams.consignee" placeholder="请输入收货人" clearable @keyup.enter="handleQuery" />
        </el-form-item>
        <el-form-item label="手机号">
          <el-input v-model="queryParams.phone" placeholder="请输入手机号" clearable @keyup.enter="handleQuery" />
        </el-form-item>
        <el-form-item label="下单时间">
          <el-date-picker
            v-model="dateRange"
            type="datetimerange"
            range-separator="至"
            start-placeholder="开始时间"
            end-placeholder="结束时间"
            value-format="YYYY-MM-DD HH:mm:ss"
            @change="handleDateChange"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery" :icon="Search">查询</el-button>
          <el-button @click="handleReset" :icon="Refresh">重置</el-button>
          <el-button type="success" @click="handleExport" :icon="Download">导出订单</el-button>
        </el-form-item>
      </el-form>
    </div>

    <div class="page-container">
      <el-tabs v-model="activeStatus" @tab-click="handleTabClick" class="order-tabs">
        <el-tab-pane label="全部订单" name="all" />
        <el-tab-pane label="待付款" name="1" />
        <el-tab-pane label="待接单" name="2" />
        <el-tab-pane label="已接单" name="3" />
        <el-tab-pane label="配送中" name="4" />
        <el-tab-pane label="已完成" name="5" />
        <el-tab-pane label="已取消" name="6" />
      </el-tabs>

      <el-table 
        v-loading="loading" 
        :data="tableData" 
        border 
        stripe
        highlight-current-row
        style="width: 100%"
      >
        <el-table-column prop="number" label="订单号" min-width="180" show-overflow-tooltip />
        <el-table-column prop="consignee" label="收货人" width="120" show-overflow-tooltip />
        <el-table-column prop="phone" label="手机号" width="130" />
        <el-table-column prop="amount" label="金额" width="120" sortable>
          <template #default="{ row }">
            <span class="price">¥{{ row.amount }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="120" align="center">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)" effect="light" round>
              {{ row.statusLabel }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="orderTime" label="下单时间" min-width="180" sortable />
        <el-table-column prop="branchName" label="分店" min-width="150" show-overflow-tooltip />
        <el-table-column label="操作" width="220" fixed="right" align="center">
          <template #default="{ row }">
            <el-button link type="primary" @click="handleDetail(row)">详情</el-button>
            
            <el-button
              v-if="row.status === 2"
              link
              type="success"
              @click="handleAccept(row)"
            >
              接单
            </el-button>
            
            <el-button
              v-if="row.status === 3"
              link
              type="warning"
              @click="handleDelivery(row)"
            >
              派送
            </el-button>
            
            <el-button
              v-if="row.status === 4"
              link
              type="success"
              @click="handleComplete(row)"
            >
              完成
            </el-button>
            
            <el-button
              v-if="[2, 3].includes(row.status)"
              link
              type="danger"
              @click="handleCancel(row)"
            >
              取消
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-container">
        <el-pagination
          v-model:current-page="queryParams.pageNum"
          v-model:page-size="queryParams.pageSize"
          :total="total"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleQuery"
          @current-change="handleQuery"
        />
      </div>
    </div>

    <!-- 订单详情弹窗 -->
    <OrderDetail v-model="detailVisible" :order-id="currentOrderId" />
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Download } from '@element-plus/icons-vue'
import { getOrderList, acceptOrder, cancelOrder, deliveryOrder, completeOrder, exportOrder } from '@/api/order'
import { saveAs } from 'file-saver'
import OrderDetail from './OrderDetail.vue'

const loading = ref(false)
const total = ref(0)
const tableData = ref([])
const dateRange = ref([])
const activeStatus = ref('all')
const detailVisible = ref(false)
const currentOrderId = ref(null)

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  number: '',
  phone: '',
  consignee: '',
  status: undefined,
  beginTime: '',
  endTime: ''
})

const handleTabClick = (tab) => {
  if (tab.props.name === 'all') {
    queryParams.status = undefined
  } else {
    queryParams.status = parseInt(tab.props.name)
  }
  handleQuery()
}

const handleDateChange = (val) => {
  if (val) {
    queryParams.beginTime = val[0]
    queryParams.endTime = val[1]
  } else {
    queryParams.beginTime = ''
    queryParams.endTime = ''
  }
}

const handleQuery = async () => {
  loading.value = true
  try {
    const res = await getOrderList(queryParams)
    if (res.code === 200) {
      tableData.value = (res.data.list || []).map(item => ({
        ...item,
        statusLabel: getStatusLabel(item.status)
      }))
      total.value = res.data.total || 0
    }
  } catch (error) {
    console.error('查询订单列表失败:', error)
  } finally {
    loading.value = false
  }
}

const handleReset = () => {
  queryParams.number = ''
  queryParams.phone = ''
  queryParams.consignee = ''
  queryParams.status = activeStatus.value === 'all' ? undefined : parseInt(activeStatus.value)
  dateRange.value = []
  queryParams.beginTime = ''
  queryParams.endTime = ''
  handleQuery()
}

const handleDetail = (row) => {
  currentOrderId.value = row.id
  detailVisible.value = true
}

const handleAccept = async (row) => {
  try {
    await ElMessageBox.confirm('确认接单？', '提示', {
      type: 'info'
    })
    await acceptOrder(row.id)
    ElMessage.success('接单成功')
    handleQuery()
  } catch (error) {
    if (error !== 'cancel') console.error(error)
  }
}

const handleDelivery = async (row) => {
  try {
    await ElMessageBox.confirm('确认派送订单？', '提示', {
      type: 'info'
    })
    await deliveryOrder(row.id)
    ElMessage.success('派送成功')
    handleQuery()
  } catch (error) {
    if (error !== 'cancel') console.error(error)
  }
}

const handleComplete = async (row) => {
  try {
    await ElMessageBox.confirm('确认订单已送达？', '提示', {
      type: 'success'
    })
    await completeOrder(row.id)
    ElMessage.success('订单完成')
    handleQuery()
  } catch (error) {
    if (error !== 'cancel') console.error(error)
  }
}

const handleCancel = async (row) => {
  try {
    await ElMessageBox.prompt('请输入取消原因', '取消订单', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      inputPattern: /\S/,
      inputErrorMessage: '取消原因不能为空'
    }).then(async ({ value }) => {
      await cancelOrder({ id: row.id, cancelReason: value })
      ElMessage.success('取消成功')
      handleQuery()
    })
  } catch (error) {
    if (error !== 'cancel') console.error(error)
  }
}

const handleExport = async () => {
  try {
    const res = await exportOrder(queryParams)
    const blob = res.data
    const disposition = res.headers['content-disposition'] || ''
    let filename = '订单列表.xlsx'
    const match = /filename\*=UTF-8''([^;]+)|filename="?([^";]+)"?/i.exec(disposition)
    if (match) {
      filename = decodeURIComponent(match[1] || match[2])
    }
    saveAs(blob, filename)
    ElMessage.success('导出成功')
  } catch (error) {
    console.error('导出订单失败:', error)
    ElMessage.error('导出失败')
  }
}

const getStatusType = (status) => {
  const map = {
    1: 'warning', // 待付款
    2: 'danger',  // 待接单
    3: 'primary', // 已接单
    4: 'success', // 配送中
    5: 'success', // 已完成
    6: 'info'     // 已取消
  }
  return map[status] || 'info'
}

const getStatusLabel = (status) => {
  const map = {
    1: '待付款',
    2: '待接单',
    3: '已接单',
    4: '配送中',
    5: '已完成',
    6: '已取消'
  }
  return map[status] || '未知'
}

onMounted(() => {
  handleQuery()
})
</script>

<style lang="scss" scoped>
.price {
  color: #f56c6c;
  font-weight: bold;
}
.order-tabs {
  margin-bottom: 20px;
}
</style>
