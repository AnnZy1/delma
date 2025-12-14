<template>
  <div class="app-container">
    <div class="search-container">
      <el-form :model="queryParams" :inline="true">
        <el-form-item label="员工姓名">
          <el-input 
            v-model="queryParams.name" 
            placeholder="请输入员工姓名" 
            clearable 
            prefix-icon="Search"
            @keyup.enter="handleQuery" 
          />
        </el-form-item>
        <el-form-item label="用户名">
          <el-input 
            v-model="queryParams.username" 
            placeholder="请输入用户名" 
            clearable 
            prefix-icon="User"
            @keyup.enter="handleQuery" 
          />
        </el-form-item>
        <el-form-item label="手机号">
          <el-input 
            v-model="queryParams.phone" 
            placeholder="请输入手机号" 
            clearable 
            prefix-icon="Iphone"
            @keyup.enter="handleQuery" 
          />
        </el-form-item>
        <el-form-item label="分店" v-if="userStore.isAdmin">
          <el-select v-model="queryParams.branchId" placeholder="请选择分店" clearable>
            <el-option
              v-for="branch in branchList"
              :key="branch.id"
              :label="branch.name"
              :value="branch.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="queryParams.status" placeholder="请选择状态" clearable>
            <el-option label="正常" :value="1" />
            <el-option label="锁定" :value="0" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :icon="Search" @click="handleQuery">查询</el-button>
          <el-button :icon="Refresh" @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <div class="page-container">
      <div class="table-operations">
        <div class="left">
          <el-button type="primary" :icon="Plus" @click="handleAdd">新增员工</el-button>
          <el-button 
            type="success" 
            plain
            :icon="Check"
            :disabled="!selectedIds.length" 
            @click="handleBatchUnlock"
          >
            批量启用
          </el-button>
          <el-button 
            type="warning" 
            plain
            :icon="Lock"
            :disabled="!selectedIds.length" 
            @click="handleBatchLock"
          >
            批量锁定
          </el-button>
          <el-button 
            type="danger" 
            plain
            :icon="Delete"
            :disabled="!selectedIds.length" 
            @click="handleBatchDelete"
          >
            批量删除
          </el-button>
        </div>
      </div>

      <el-table
        v-loading="loading"
        :data="tableData"
        @selection-change="handleSelectionChange"
        border
        stripe
        highlight-current-row
      >
        <el-table-column type="selection" width="55" align="center" />
        <el-table-column prop="username" label="用户名" min-width="120" show-overflow-tooltip />
        <el-table-column prop="name" label="姓名" min-width="120" show-overflow-tooltip />
        <el-table-column prop="phone" label="手机号" min-width="130" align="center" />
        <el-table-column prop="sex" label="性别" min-width="80" align="center" />
        <el-table-column prop="roleName" label="角色" min-width="120" align="center">
          <template #default="{ row }">
            <el-tag effect="plain" type="info">{{ row.roleName || '暂无' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="branchName" label="分店" min-width="150" show-overflow-tooltip />
        <el-table-column prop="status" label="状态" min-width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'danger'" effect="dark">
              {{ row.status === 1 ? '正常' : '锁定' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180" align="center" />
        <el-table-column label="操作" width="350" fixed="right" align="center">
          <template #default="{ row }">
            <el-button link type="primary" :icon="Edit" @click="handleEdit(row)">编辑</el-button>
            <el-button link type="warning" :icon="Key" @click="handleResetPwd(row)">重置密码</el-button>
            <el-button
              link
              :type="row.status === 1 ? 'danger' : 'success'"
              :icon="row.status === 1 ? Lock : Unlock"
              @click="handleToggleStatus(row)"
            >
              {{ row.status === 1 ? '锁定' : '启用' }}
            </el-button>
            <el-button link type="danger" :icon="Delete" @click="handleDelete(row)">删除</el-button>
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
          background
          @size-change="handleQuery"
          @current-change="handleQuery"
        />
      </div>
    </div>

    <!-- 新增/编辑对话框 -->
    <EmployeeForm
      v-model="formVisible"
      :form-data="formData"
      @success="handleQuery"
    />
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Plus, Delete, Lock, Unlock, Check, Edit, Key, User, Iphone } from '@element-plus/icons-vue'
import { getEmployeeList, batchEmployee, resetPassword } from '@/api/employee'
import { getBranchList } from '@/api/branch'
import { formatDateTime } from '@/utils/format'
import { useUserStore } from '@/stores/user'
import EmployeeForm from './EmployeeForm.vue'

const userStore = useUserStore()
const loading = ref(false)
const tableData = ref([])
const total = ref(0)
const selectedIds = ref([])
const formVisible = ref(false)
const formData = ref({})
const branchList = ref([])

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  name: '',
  username: '',
  phone: '',
  branchId: null,
  status: null
})

// 查询列表
const handleQuery = async () => {
  loading.value = true
  try {
    // 处理查询参数，空字符串转为 null
    const params = { ...queryParams }
    if (params.branchId === '') params.branchId = null
    if (params.status === '') params.status = null
    
    const res = await getEmployeeList(params)
    if (res.code === 200) {
      tableData.value = res.data.list.map(item => ({
        ...item,
        createTime: formatDateTime(item.createTime)
      }))
      total.value = res.data.total
    }
  } catch (error) {
    console.error('查询失败:', error)
  } finally {
    loading.value = false
  }
}

// 加载分店列表
const loadBranchList = async () => {
  try {
    const res = await getBranchList({ pageNum: 1, pageSize: 1000, status: 1 })
    if (res.code === 200) {
      branchList.value = res.data.list || []
    }
  } catch (error) {
    console.error('加载分店列表失败:', error)
  }
}

// 重置查询
const handleReset = () => {
  Object.assign(queryParams, {
    pageNum: 1,
    pageSize: 10,
    name: '',
    username: '',
    phone: '',
    branchId: !userStore.isAdmin ? userStore.branchId : null,
    status: null
  })
  handleQuery()
}

// 新增
const handleAdd = () => {
  formData.value = {}
  formVisible.value = true
}

// 编辑
const handleEdit = (row) => {
  formData.value = { ...row }
  formVisible.value = true
}

// 删除
const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm('确定要删除该员工吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning',
      confirmButtonClass: 'el-button--danger'
    })
    await batchEmployee({
      ids: [row.id],
      operation: 'delete'
    })
    ElMessage.success('删除成功')
    handleQuery()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除失败:', error)
    }
  }
}

// 重置密码
const handleResetPwd = async (row) => {
  try {
    await ElMessageBox.confirm('确定要重置该员工的密码吗？默认密码：123456', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await resetPassword({ employeeId: row.id })
    ElMessage.success('密码重置成功')
  } catch (error) {
    if (error !== 'cancel') {
      console.error('重置密码失败:', error)
    }
  }
}

// 切换状态
const handleToggleStatus = async (row) => {
  const operation = row.status === 1 ? 'lock' : 'unlock'
  try {
    await batchEmployee({
      ids: [row.id],
      operation
    })
    ElMessage.success('操作成功')
    handleQuery()
  } catch (error) {
    console.error('操作失败:', error)
  }
}

// 批量删除
const handleBatchDelete = async () => {
  try {
    await ElMessageBox.confirm(`确定要删除选中的 ${selectedIds.value.length} 名员工吗？`, '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning',
      confirmButtonClass: 'el-button--danger'
    })
    await batchEmployee({
      ids: selectedIds.value,
      operation: 'delete'
    })
    ElMessage.success('删除成功')
    // selectedIds.value = [] // table handles selection state, but we should probably rely on selection-change
    handleQuery()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除失败:', error)
    }
  }
}

// 批量锁定
const handleBatchLock = async () => {
  try {
    await batchEmployee({
      ids: selectedIds.value,
      operation: 'lock'
    })
    ElMessage.success('锁定成功')
    handleQuery()
  } catch (error) {
    console.error('锁定失败:', error)
  }
}

// 批量启用
const handleBatchUnlock = async () => {
  try {
    await batchEmployee({
      ids: selectedIds.value,
      operation: 'unlock'
    })
    ElMessage.success('启用成功')
    handleQuery()
  } catch (error) {
    console.error('启用失败:', error)
  }
}

// 选择变化
const handleSelectionChange = (selection) => {
  selectedIds.value = selection.map(item => item.id)
}

onMounted(() => {
  if (!userStore.isAdmin && userStore.branchId) {
    queryParams.branchId = userStore.branchId
  }
  handleQuery()
  loadBranchList()
})
</script>

<style lang="scss" scoped>
/* 样式已迁移至全局 styles/index.scss */
</style>