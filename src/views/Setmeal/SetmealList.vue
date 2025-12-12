<template>
  <div class="app-container">
    <div class="search-container">
      <el-form :model="queryParams" :inline="true">
        <el-form-item label="套餐名称">
          <el-input 
            v-model="queryParams.name" 
            placeholder="请输入套餐名称" 
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
        <el-form-item label="分类">
          <el-select v-model="queryParams.categoryId" placeholder="请选择分类" clearable>
            <el-option
              v-for="category in categoryList"
              :key="category.id"
              :label="category.name"
              :value="category.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="queryParams.status" placeholder="请选择状态" clearable>
            <el-option label="起售" :value="1" />
            <el-option label="停售" :value="0" />
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
          <el-button type="primary" :icon="Plus" @click="handleAdd">新增套餐</el-button>
          <el-button 
            type="success" 
            plain
            :icon="Check"
            :disabled="!selectedIds.length" 
            @click="handleBatchOnSale"
          >
            批量起售
          </el-button>
          <el-button 
            type="danger" 
            plain
            :icon="Close"
            :disabled="!selectedIds.length" 
            @click="handleBatchOffSale"
          >
            批量停售
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
        <div class="right">
          <el-button type="success" plain :icon="Download" @click="handleExport">导出</el-button>
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
        <el-table-column prop="image" label="图片" width="150" align="center">
          <template #default="{ row }">
            <el-image
              v-if="row.image"
              :src="row.image"
              :preview-src-list="[row.image]"
              style="width: 60px; height: 60px; border-radius: 4px;"
              fit="cover"
              preview-teleported
            >
              <template #error>
                <div class="image-slot">
                  <el-icon><Picture /></el-icon>
                </div>
              </template>
            </el-image>
            <span v-else class="no-image">无图片</span>
          </template>
        </el-table-column>
        <el-table-column prop="name" label="套餐名称" min-width="120" show-overflow-tooltip />
        <el-table-column prop="branchName" label="所属分店" min-width="120" show-overflow-tooltip />
        <el-table-column prop="categoryName" label="分类" width="120" align="center">
          <template #default="{ row }">
            <el-tag effect="plain">{{ row.categoryName }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="price" label="价格" width="100" align="center">
          <template #default="{ row }">
            <span class="price">¥{{ row.price.toFixed(2) }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'" effect="dark">
              {{ row.status === 1 ? '起售' : '停售' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="包含菜品" min-width="200" show-overflow-tooltip>
          <template #default="{ row }">
            <div v-if="row.setmealDishes && row.setmealDishes.length > 0" class="dish-list">
              <el-tag 
                v-for="(dish, index) in row.setmealDishes" 
                :key="index" 
                size="small"
                class="dish-item"
              >
                {{ dish.name }} x {{ dish.copies }}
              </el-tag>
            </div>
            <span v-else class="no-data">-</span>
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
    <SetmealForm v-model="formVisible" :form-data="formData" @success="handleQuery" />
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Plus, Delete, Check, Close, Edit, Download, Picture } from '@element-plus/icons-vue'
import { getSetmealList, deleteSetmeal, exportSetmeal, batchSetmeal } from '@/api/setmeal'
import { getCategoryList } from '@/api/category'
import { getBranchList } from '@/api/branch'
import { formatDateTime } from '@/utils/format'
import { useUserStore } from '@/stores/user'
import SetmealForm from './SetmealForm.vue'

const userStore = useUserStore()
const loading = ref(false)
const tableData = ref([])
const total = ref(0)
const selectedIds = ref([])
const formVisible = ref(false)
const formData = ref({})
const categoryList = ref([])
const branchList = ref([])

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  name: '',
  categoryId: null,
  branchId: null,
  status: null
})

// 查询列表
const handleQuery = async () => {
  loading.value = true
  try {
    const res = await getSetmealList(queryParams)
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

// 加载分类列表
const loadCategoryList = async () => {
  try {
    const params = { pageNum: 1, pageSize: 1000, type: 2 }
    if (!userStore.isAdmin && userStore.branchId) {
      params.branchId = userStore.branchId
    }
    const res = await getCategoryList(params)
    if (res.code === 200) {
      categoryList.value = res.data.list || []
    }
  } catch (error) {
    console.error('加载分类列表失败:', error)
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
    categoryId: null,
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
    await ElMessageBox.confirm('确定要将该套餐放入回收站吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning',
      confirmButtonClass: 'el-button--danger'
    })
    await deleteSetmeal(row.id)
    ElMessage.success('放入回收站成功')
    handleQuery()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除失败:', error)
    }
  }
}

// 批量起售
const handleBatchOnSale = async () => {
  try {
    await ElMessageBox.confirm(`确定要起售选中的 ${selectedIds.value.length} 个套餐吗？`, '提示', {
      type: 'warning'
    })
    await batchSetmeal({ ids: selectedIds.value, status: 1 })
    ElMessage.success('批量起售成功')
    handleQuery()
  } catch (error) {
    if (error !== 'cancel') console.error(error)
  }
}

// 批量停售
const handleBatchOffSale = async () => {
  try {
    await ElMessageBox.confirm(`确定要停售选中的 ${selectedIds.value.length} 个套餐吗？`, '提示', {
      type: 'warning'
    })
    await batchSetmeal({ ids: selectedIds.value, status: 0 })
    ElMessage.success('批量停售成功')
    handleQuery()
  } catch (error) {
    if (error !== 'cancel') console.error(error)
  }
}

// 批量删除
const handleBatchDelete = async () => {
  try {
    await ElMessageBox.confirm(`确定要将选中的 ${selectedIds.value.length} 个套餐放入回收站吗？`, '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning',
      confirmButtonClass: 'el-button--danger'
    })
    
    // 循环调用删除接口
    const deletePromises = selectedIds.value.map(id => deleteSetmeal(id))
    await Promise.all(deletePromises)
    
    ElMessage.success('批量放入回收站成功')
    handleQuery()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('批量删除失败:', error)
      ElMessage.error('部分套餐删除失败，请重试')
    }
  }
}


// 导出
const handleExport = async () => {
  try {
    const res = await exportSetmeal(queryParams)
    const blob = new Blob([res], {
      type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    })
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `套餐列表_${new Date().getTime()}.xlsx`
    link.click()
    window.URL.revokeObjectURL(url)
    ElMessage.success('导出成功')
  } catch (error) {
    console.error('导出失败:', error)
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
  loadCategoryList()
  loadBranchList()
})
</script>

<style lang="scss" scoped>
.price {
  color: #f56c6c;
  font-weight: bold;
}

.dish-list {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}

.no-image {
  color: #909399;
  font-size: 12px;
}

.image-slot {
  display: flex;
  justify-content: center;
  align-items: center;
  width: 100%;
  height: 100%;
  background: #f5f7fa;
  color: #909399;
  font-size: 20px;
}

.no-data {
  color: #909399;
}
</style>