<template>
  <div class="app-container">
    <!-- 搜索栏 -->
    <div class="search-container">
      <el-form :model="queryParams" :inline="true">
        <el-form-item label="员工ID">
          <el-input 
            v-model="queryParams.employeeId" 
            placeholder="请输入员工ID" 
            clearable 
            prefix-icon="User"
            @keyup.enter="handleQuery" 
          />
        </el-form-item>
        <el-form-item label="员工姓名">
          <el-input 
            v-model="queryParams.name" 
            placeholder="请输入员工姓名" 
            clearable 
            prefix-icon="User"
            @keyup.enter="handleQuery" 
          />
        </el-form-item>
        <el-form-item label="登录时间">
          <el-date-picker
            v-model="dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            value-format="YYYY-MM-DD"
            @change="handleDateChange"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :icon="Search" @click="handleQuery">查询</el-button>
          <el-button :icon="Refresh" @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <!-- 表格区域 -->
    <div class="page-container">
      <el-table
        v-loading="loading"
        :data="tableData"
        border
        stripe
        highlight-current-row
      >
        <el-table-column type="index" label="序号" width="80" align="center" />
        <el-table-column prop="employeeId" label="员工ID" width="100" align="center" />
        <el-table-column prop="name" label="员工姓名" width="120" align="center" />
        <el-table-column prop="username" label="用户名" width="120" align="center" />
        <el-table-column prop="ip" label="登录IP" width="150" align="center" />
        <el-table-column prop="address" label="登录地点" width="200" show-overflow-tooltip />
        <el-table-column prop="browser" label="浏览器" width="150" show-overflow-tooltip />
        <el-table-column prop="os" label="操作系统" width="150" show-overflow-tooltip />
        <el-table-column prop="status" label="状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'danger'" effect="dark">
              {{ row.status === 1 ? '成功' : '失败' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="msg" label="提示信息" min-width="200" show-overflow-tooltip />
        <el-table-column prop="loginTime" label="登录时间" width="180" align="center" />
      </el-table>

      <!-- 分页 -->
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="queryParams.pageNum"
          v-model:page-size="queryParams.pageSize"
          :total="total"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          background
          @size-change="handleQuery"
          @current-change="handleQuery"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { Search, Refresh } from '@element-plus/icons-vue'
import { getLoginLogList } from '@/api/log'
import { formatDateTime } from '@/utils/format'

const loading = ref(false)
const tableData = ref([])
const total = ref(0)
const dateRange = ref([])

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  employeeId: '',
  name: '',
  beginTime: '',
  endTime: ''
})

// 查询列表
const handleQuery = async () => {
  loading.value = true
  try {
    const res = await getLoginLogList(queryParams)
    if (res.code === 200) {
      tableData.value = res.data.list.map(item => ({
        ...item,
        loginTime: formatDateTime(item.loginTime)
      }))
      total.value = res.data.total
    }
  } catch (error) {
    console.error('查询失败:', error)
  } finally {
    loading.value = false
  }
}

// 重置查询
const handleReset = () => {
  dateRange.value = []
  Object.assign(queryParams, {
    pageNum: 1,
    pageSize: 10,
    employeeId: '',
    name: '',
    beginTime: '',
    endTime: ''
  })
  handleQuery()
}

// 日期范围变化
const handleDateChange = (val) => {
  if (val && val.length === 2) {
    queryParams.beginTime = val[0] + ' 00:00:00'
    queryParams.endTime = val[1] + ' 23:59:59'
  } else {
    queryParams.beginTime = ''
    queryParams.endTime = ''
  }
}

onMounted(() => {
  handleQuery()
})
</script>

<style lang="scss" scoped>
// 样式已在全局 index.scss 中定义，此处无需额外样式
</style>
