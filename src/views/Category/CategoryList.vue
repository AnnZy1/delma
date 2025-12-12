<template>
  <div class="app-container">
    <div class="search-container">
      <el-form :model="queryParams" :inline="true">
        <el-form-item label="分类名称">
          <el-input 
            v-model="queryParams.name" 
            placeholder="请输入分类名称" 
            clearable 
            prefix-icon="Search"
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
        <el-form-item label="类型">
          <el-select v-model="queryParams.type" placeholder="请选择类型" clearable>
            <el-option label="菜品" :value="1" />
            <el-option label="套餐" :value="2" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="queryParams.status" placeholder="请选择状态" clearable>
            <el-option label="启用" :value="1" />
            <el-option label="禁用" :value="0" />
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
          <el-button type="primary" :icon="Plus" @click="handleAdd">新增分类</el-button>
          <el-button 
            type="success" 
            plain 
            :icon="Check"
            :disabled="!selectedIds.length" 
            @click="handleBatchEnable"
          >
            批量启用
          </el-button>
          <el-button 
            type="danger" 
            plain 
            :icon="Close"
            :disabled="!selectedIds.length" 
            @click="handleBatchDisable"
          >
            批量禁用
          </el-button>
        </div>
      </div>

      <el-table
        v-loading="loading"
        :data="tableData"
        row-key="id"
        @selection-change="handleSelectionChange"
        border
        stripe
        highlight-current-row
      >
        <el-table-column type="selection" width="55" align="center" />
        <el-table-column prop="name" label="分类名称" min-width="150" show-overflow-tooltip />
        <el-table-column prop="type" label="类型" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="row.type === 1 ? 'primary' : 'warning'" effect="plain">
              {{ row.type === 1 ? '菜品' : '套餐' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="sort" label="排序" width="100" align="center" />
        <el-table-column prop="status" label="状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'danger'" effect="dark">
              {{ row.status === 1 ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180" align="center" />
        <el-table-column label="操作" width="200" fixed="right" align="center">
          <template #default="{ row }">
            <el-button link type="primary" :icon="Edit" @click="handleEdit(row)">编辑</el-button>
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
    <CategoryForm v-model="formVisible" :form-data="formData" @success="handleQuery" />
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Plus, Edit, Delete, Check, Close } from '@element-plus/icons-vue'
import { getCategoryList, deleteCategory, batchCategory } from '@/api/category'
import { getBranchList } from '@/api/branch'
import { formatDateTime } from '@/utils/format'
import { useUserStore } from '@/stores/user'
import CategoryForm from './CategoryForm.vue'

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
  type: null,
  branchId: null,
  status: null
})

// 查询列表
const handleQuery = async () => {
  loading.value = true
  try {
    const res = await getCategoryList(queryParams)
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
    type: null,
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
    await ElMessageBox.confirm('确定要删除该分类吗？如果该分类下关联了菜品或套餐，删除将失败。', '警告', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning',
      confirmButtonClass: 'el-button--danger'
    })
    await deleteCategory(row.id)
    ElMessage.success('删除成功')
    handleQuery()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除失败:', error)
      ElMessage.error(error.msg || '删除失败，该分类下可能还有关联的菜品或套餐')
    }
  }
}

// 批量禁用
const handleBatchDisable = async () => {
  try {
    await ElMessageBox.confirm(`确定要禁用选中的 ${selectedIds.value.length} 个分类吗？`, '提示', {
      type: 'warning'
    })
    await batchCategory({
      ids: selectedIds.value,
      operation: 'disable'
    })
    ElMessage.success('批量禁用成功')
    handleQuery()
  } catch (error) {
    if (error !== 'cancel') console.error('批量禁用失败:', error)
  }
}

// 批量启用
const handleBatchEnable = async () => {
  try {
    await ElMessageBox.confirm(`确定要启用选中的 ${selectedIds.value.length} 个分类吗？`, '提示', {
      type: 'warning'
    })
    await batchCategory({
      ids: selectedIds.value,
      operation: 'enable'
    })
    ElMessage.success('批量启用成功')
    handleQuery()
  } catch (error) {
    if (error !== 'cancel') console.error('批量启用失败:', error)
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