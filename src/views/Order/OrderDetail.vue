<template>
  <el-dialog v-model="dialogVisible" title="订单详情" width="800px" @close="handleClose">
    <div v-loading="loading" class="order-detail">
      <el-descriptions :column="2" border>
        <el-descriptions-item label="订单号">{{ orderDetail?.number }}</el-descriptions-item>
        <el-descriptions-item label="订单状态">
          <el-tag :type="getStatusType(orderDetail?.status)">
            {{ orderDetail?.statusLabel }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="收货人">{{ orderDetail?.consignee }}</el-descriptions-item>
        <el-descriptions-item label="手机号">{{ orderDetail?.phone }}</el-descriptions-item>
        <el-descriptions-item label="收货地址" :span="2">
          {{ orderDetail?.address }}
        </el-descriptions-item>
        <el-descriptions-item label="订单金额">¥{{ orderDetail?.amount }}</el-descriptions-item>
        <el-descriptions-item label="下单时间">{{ orderDetail?.orderTime }}</el-descriptions-item>
        <el-descriptions-item label="分店">{{ orderDetail?.branchName }}</el-descriptions-item>
        <el-descriptions-item label="备注" :span="2">{{ orderDetail?.remark || '-' }}</el-descriptions-item>
        <el-descriptions-item label="取消原因" :span="2" v-if="orderDetail?.cancelReason">{{ orderDetail?.cancelReason }}</el-descriptions-item>
      </el-descriptions>

      <el-divider>商品明细</el-divider>

      <el-table :data="orderDetail?.orderDetails" border>
        <el-table-column prop="name" label="商品名称" />
        <el-table-column prop="number" label="数量" width="80" />
        <el-table-column prop="amount" label="单价" width="100">
          <template #default="{ row }">¥{{ row.amount }}</template>
        </el-table-column>
        <el-table-column label="小计" width="100">
          <template #default="{ row }">¥{{ (row.amount * row.number).toFixed(2) }}</template>
        </el-table-column>
      </el-table>
    </div>
  </el-dialog>
</template>

<script setup>
import { ref, watch } from 'vue'
import { getOrderDetail } from '@/api/order'
import { formatDateTime } from '@/utils/format'

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false
  },
  orderId: {
    type: Number,
    default: null
  }
})

const emit = defineEmits(['update:modelValue'])

const dialogVisible = ref(false)
const loading = ref(false)
const orderDetail = ref(null)

// 监听对话框显示
watch(() => props.modelValue, (val) => {
  dialogVisible.value = val
  if (val && props.orderId) {
    loadOrderDetail()
  }
})

// 监听对话框内部状态
watch(dialogVisible, (val) => {
  emit('update:modelValue', val)
})

// 加载订单详情
const loadOrderDetail = async () => {
  loading.value = true
  try {
    const res = await getOrderDetail(props.orderId)
    if (res.code === 200) {
      orderDetail.value = {
        ...res.data,
        orderTime: formatDateTime(res.data.orderTime)
      }
    }
  } catch (error) {
    console.error('加载订单详情失败:', error)
  } finally {
    loading.value = false
  }
}

// 获取状态类型
const getStatusType = (status) => {
  const types = {
    1: 'warning',
    2: 'info',
    3: 'primary',
    4: 'success',
    5: 'success',
    6: 'danger'
  }
  return types[status] || 'info'
}

// 关闭
const handleClose = () => {
  dialogVisible.value = false
  orderDetail.value = null
}
</script>

<style lang="scss" scoped>
.order-detail {
  .el-descriptions {
    margin-bottom: 20px;
  }
}
</style>

