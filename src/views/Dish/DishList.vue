<template>
  <div class="app-container">
    <!-- Tabs标签页布局 -->
    <el-tabs v-model="activeTab" type="card" @tab-change="handleTabChange">
      <!-- Tab 1: 在售/待售列表 -->
      <el-tab-pane label="在售/待售列表" name="active">
        <div class="search-container">
          <el-form :model="queryParams" :inline="true">
            <el-form-item label="菜品名称">
              <el-input 
                v-model="queryParams.name" 
                placeholder="请输入菜品名称" 
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
      </el-tab-pane>
      
      <!-- Tab 2: 回收站 -->
      <el-tab-pane label="回收站" name="deleted">
        <div class="search-container">
          <el-form :model="queryParams" :inline="true">
            <el-form-item label="菜品名称">
              <el-input 
                v-model="queryParams.name" 
                placeholder="请输入菜品名称" 
                clearable 
                prefix-icon="Search"
                @keyup.enter="handleQuery"
              />
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
            <el-form-item>
              <el-button type="primary" :icon="Search" @click="handleQuery">查询</el-button>
              <el-button :icon="Refresh" @click="handleReset">重置</el-button>
            </el-form-item>
          </el-form>
        </div>
      </el-tab-pane>
    </el-tabs>

    <div class="page-container">
      <div class="table-operations">
        <div class="left">
          <!-- 在售/待售列表的操作按钮 -->
          <el-button v-if="activeTab === 'active'" type="primary" :icon="Plus" @click="handleAdd">新增菜品</el-button>
          <el-button 
            v-if="activeTab === 'active'"
            type="success" 
            plain 
            :icon="Check"
            :disabled="!selectedIds.length" 
            @click="handleBatchOnSale"
          >
            批量起售
          </el-button>
          <el-button 
            v-if="activeTab === 'active'"
            type="danger" 
            plain 
            :icon="Close"
            :disabled="!selectedIds.length" 
            @click="handleBatchOffSale"
          >
            批量停售
          </el-button>
          
          <!-- 回收站的操作按钮 -->
          <el-button 
            v-if="activeTab === 'deleted'"
            type="success" 
            :icon="Refresh"
            :disabled="!selectedIds.length" 
            @click="handleBatchRestore"
          >
            批量恢复
          </el-button>
          <el-button 
            v-if="activeTab === 'deleted'"
            type="danger" 
            :icon="Delete"
            :disabled="!selectedIds.length" 
            @click="handleBatchDeletePermanently"
          >
            批量永久删除
          </el-button>
        </div>
        <div class="right">
          <el-button type="primary" plain :icon="Upload" @click="handleImport">导入</el-button>
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
        <el-table-column label="图片" width="200" align="center">
          <template #default="{ row }">
            <el-image
              v-if="row.image"
              :src="row.image"
              :preview-src-list="[row.image]"
              style="width: 80px; height: 80px; border-radius: 4px;"
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
        <el-table-column prop="name" label="菜品名称" width="100" min-width="180" max-width="300" show-overflow-tooltip />
        <el-table-column prop="categoryName" label="分类" width="140" align="center">
          <template #default="{ row }">
            <el-tag effect="plain">{{ row.categoryName }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="price" label="价格" width="100" align="center">
          <template #default="{ row }">
            <span class="price">¥{{ row.price.toFixed(2) }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="120" align="center">
          <template #default="{ row }">
            <!-- 在售/待售列表的状态显示 -->
            <template v-if="activeTab === 'active'">
              <el-tag :type="row.status === 1 ? 'success' : 'info'" effect="dark">
                {{ row.status === 1 ? '起售' : '停售' }}
              </el-tag>
            </template>
            
            <!-- 回收站的状态显示（灰色不可操作） -->
            <template v-if="activeTab === 'deleted'">
              <el-tag type="info" effect="plain" :disable-transitions="true">
                {{ row.status === 1 ? '已删除(原起售)' : '已删除(原停售)' }}
              </el-tag>
            </template>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180" align="center" />
        <el-table-column label="操作" width="220" fixed="right" align="center">
          <template #default="{ row }">
            <!-- 在售/待售列表的操作按钮 -->
            <template v-if="activeTab === 'active'">
              <el-button link type="primary" :icon="Edit" @click="handleEdit(row)">编辑</el-button>
              <el-button link type="danger" :icon="Delete" @click="handleDelete(row)">删除</el-button>
            </template>
            
            <!-- 回收站的操作按钮 -->
            <template v-if="activeTab === 'deleted'">
              <el-button link type="success" :icon="Refresh" @click="handleRestore(row)">恢复</el-button>
              <el-button link type="danger" :icon="Delete" @click="handleDeletePermanently(row)">永久删除</el-button>
            </template>
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
    <DishForm v-model="formVisible" :form-data="formData" @success="handleQuery" />

    <!-- 导入对话框 -->
    <el-dialog v-model="importVisible" title="导入菜品" width="500px">
      <el-upload
        :action="importUrl"
        :headers="uploadHeaders"
        :on-success="handleImportSuccess"
        :on-error="handleImportError"
        :before-upload="beforeImport"
        :show-file-list="false"
        accept=".xlsx,.xls"
      >
        <el-button type="primary">选择文件</el-button>
        <template #tip>
          <div class="el-upload__tip">只能上传xlsx/xls文件</div>
        </template>
      </el-upload>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Picture, Search, Refresh, Plus, Upload, Download, Edit, Delete, Check, Close } from '@element-plus/icons-vue'
import { getDishList, batchDish, deleteDish, importDish, exportDish, restoreDish, deleteDishPermanently } from '@/api/dish'
import { getCategoryList } from '@/api/category'
import { getBranchList } from '@/api/branch'
import { formatDateTime } from '@/utils/format'
import { useUserStore } from '@/stores/user'
import DishForm from './DishForm.vue'
import { API_BASE_URL } from '@/env'

const activeTab = ref('active')

// 处理标签页切换
const handleTabChange = (tabName) => {
  activeTab.value = tabName
  // 根据标签页设置是否显示已删除的数据
  queryParams.showDeleted = tabName === 'deleted' ? 1 : 0
  // 重置查询参数
  queryParams.pageNum = 1
  // 重新查询数据
  handleQuery()
}

const userStore = useUserStore()
const loading = ref(false)
const tableData = ref([])
const total = ref(0)
const selectedIds = ref([])
const formVisible = ref(false)
const formData = ref({})
const importVisible = ref(false)
const categoryList = ref([])
const branchList = ref([])

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  name: '',
  categoryId: null,
  branchId: null,
  status: null,
  showDeleted: 0
})

const importUrl = computed(() => {
  return `${API_BASE_URL}/admin/dish/import`
})

const uploadHeaders = computed(() => {
  return {
    Authorization: `Bearer ${userStore.token}`
  }
})

// 查询列表
const handleQuery = async () => {
  loading.value = true
  try {
    // 处理查询参数，空字符串转为 null
    const params = { ...queryParams }
    if (params.categoryId === '') params.categoryId = null
    if (params.branchId === '') params.branchId = null
    if (params.status === '') params.status = null
    
    const res = await getDishList(params)
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
    const params = { pageNum: 1, pageSize: 1000, type: 1 }
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
    status: null,
    showDeleted: 0
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
    await ElMessageBox.confirm('确定要将该菜品放入回收站吗？', '警告', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning',
      confirmButtonClass: 'el-button--danger'
    })
    await deleteDish(row.id)
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
    await ElMessageBox.confirm(`确定要起售选中的 ${selectedIds.value.length} 个菜品吗？`, '提示', {
      type: 'warning'
    })
    await batchDish({ ids: selectedIds.value, operation: 'enable' })
    ElMessage.success('批量起售成功')
    handleQuery()
  } catch (error) {
    if (error !== 'cancel') console.error(error)
  }
}

// 批量恢复
 const handleBatchRestore = async () => {
   try {
     await ElMessageBox.confirm(`确定要恢复选中的 ${selectedIds.value.length} 个菜品吗？`, '提示', {
       type: 'warning'
     })
     // 批量恢复每个菜品
     for (const id of selectedIds.value) {
       await restoreDish(id)
     }
     ElMessage.success('批量恢复成功')
     handleQuery()
   } catch (error) {
     if (error !== 'cancel') console.error(error)
   }
 }
 
 // 批量永久删除
 const handleBatchDeletePermanently = async () => {
   try {
     await ElMessageBox.confirm(`确定要永久删除选中的 ${selectedIds.value.length} 个菜品吗？此操作不可恢复！`, '警告', {
       confirmButtonText: '确定',
       cancelButtonText: '取消',
       type: 'warning',
       confirmButtonClass: 'el-button--danger'
     })
     // 批量永久删除每个菜品
     for (const id of selectedIds.value) {
       await deleteDishPermanently(id)
     }
     ElMessage.success('批量永久删除成功')
     handleQuery()
   } catch (error) {
     if (error !== 'cancel') console.error(error)
   }
 }
 
 // 恢复单个菜品
 const handleRestore = async (row) => {
   try {
     await ElMessageBox.confirm('确定要恢复该菜品吗？', '提示', {
       type: 'warning'
     })
     await restoreDish(row.id)
     ElMessage.success('恢复成功')
     handleQuery()
   } catch (error) {
     if (error !== 'cancel') console.error(error)
   }
 }
 
 // 永久删除单个菜品
 const handleDeletePermanently = async (row) => {
   try {
     await ElMessageBox.confirm('确定要永久删除该菜品吗？此操作不可恢复！', '警告', {
       confirmButtonText: '确定',
       cancelButtonText: '取消',
       type: 'warning',
       confirmButtonClass: 'el-button--danger'
     })
     await deleteDishPermanently(row.id)
     ElMessage.success('永久删除成功')
     handleQuery()
   } catch (error) {
     if (error !== 'cancel') console.error(error)
   }
 }

// 批量停售
const handleBatchOffSale = async () => {
  try {
    await ElMessageBox.confirm(`确定要停售选中的 ${selectedIds.value.length} 个菜品吗？`, '提示', {
      type: 'warning'
    })
    await batchDish({ ids: selectedIds.value, operation: 'disable' })
    ElMessage.success('批量停售成功')
    handleQuery()
  } catch (error) {
    if (error !== 'cancel') console.error(error)
  }
}

// 导入
const handleImport = () => {
  importVisible.value = true
}

const beforeImport = (file) => {
  const isExcel = /\.(xlsx|xls)$/.test(file.name)
  if (!isExcel) {
    ElMessage.error('只能上传 Excel 文件')
    return false
  }
  return true
}

const handleImportSuccess = (res) => {
  if (res.code === 200) {
    ElMessage.success('导入成功')
    importVisible.value = false
    handleQuery()
  } else {
    ElMessage.error(res.msg || '导入失败')
  }
}

const handleImportError = (error) => {
  console.error('导入失败:', error)
  ElMessage.error('导入失败')
}

// 导出
const handleExport = async () => {
  try {
    const res = await exportDish(queryParams)
    const blob = res.data
    const disposition = res.headers['content-disposition'] || ''
    let filename = '菜品列表.xlsx'
    const match = /filename\*=UTF-8''([^;]+)|filename="?([^";]+)"?/i.exec(disposition)
    if (match) {
      filename = decodeURIComponent(match[1] || match[2])
    }
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = filename
    link.click()
    window.URL.revokeObjectURL(url)
    ElMessage.success('导出成功')
  } catch (error) {
    console.error('导出失败:', error)
    ElMessage.error('导出失败')
  }
}

// 选择变化
const handleSelectionChange = (selection) => {
  selectedIds.value = selection.map(item => item.id)
}

// 检查是否在回收站中，禁用状态修改
const isInRecycleBin = computed(() => {
  return activeTab.value === 'deleted'
})

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
</style>
