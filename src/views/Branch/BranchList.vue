<template>
  <div class="app-container">
    <div class="search-container">
      <el-form :model="queryParams" :inline="true">
        <el-form-item label="分店名称">
          <el-input 
            v-model="queryParams.name" 
            placeholder="请输入分店名称" 
            clearable 
            prefix-icon="Search"
            @keyup.enter="handleQuery"
          />
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
          <el-button type="primary" :icon="Plus" @click="handleAdd">新增分店</el-button>
        </div>
      </div>

      <el-table 
        v-loading="loading" 
        :data="tableData"
        border
        stripe
        highlight-current-row
      >
        <el-table-column prop="name" label="分店名称" min-width="150" show-overflow-tooltip />
        <el-table-column prop="address" label="地址" min-width="200" show-overflow-tooltip />
        <el-table-column prop="contactName" label="联系人" min-width="120" align="center" />
        <el-table-column prop="contactPhone" label="联系电话" min-width="140" align="center" />
        <el-table-column prop="status" label="状态" min-width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'danger'" effect="dark">
              {{ row.status === 1 ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" min-width="180" align="center" />
        <el-table-column label="操作" min-width="180" fixed="right" align="center">
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
    <BranchForm v-model="formVisible" :form-data="formData" @success="handleQuery" />
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Plus, Edit, Delete } from '@element-plus/icons-vue'
import { getBranchList, deleteBranch } from '@/api/branch'
import { formatDateTime } from '@/utils/format'
import BranchForm from './BranchForm.vue'

const loading = ref(false)
const tableData = ref([])
const total = ref(0)
const formVisible = ref(false)
const formData = ref({})

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  name: '',
  status: null
})

// 查询列表
const handleQuery = async () => {
  loading.value = true
  try {
    const res = await getBranchList(queryParams)
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

// 重置查询
const handleReset = () => {
  Object.assign(queryParams, {
    pageNum: 1,
    pageSize: 10,
    name: '',
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
    await ElMessageBox.confirm('确定要删除该分店吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning',
      confirmButtonClass: 'el-button--danger'
    })
    const res = await deleteBranch(row.id)
    if (res.code === 200) {
      ElMessage.success('删除成功')
      handleQuery()
    } else {
      ElMessage.error(res.msg || '删除失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除失败:', error)
      ElMessage.error(error.message || '删除失败')
    }
  }
}

onMounted(() => {
  handleQuery()
})
</script>

<style lang="scss" scoped>
// 样式已通过全局样式 index.scss 统一管理
</style>
