<template>
  <el-dialog
    v-model="dialogVisible"
    :title="formData.id ? '编辑分类' : '新增分类'"
    width="600px"
    @close="handleClose"
    destroy-on-close
    :close-on-click-modal="false"
  >
    <el-form ref="formRef" :model="form" :rules="rules" label-width="100px" class="category-form">
      <el-form-item label="分类名称" prop="name">
        <el-input v-model="form.name" placeholder="请输入分类名称" />
      </el-form-item>
      <el-form-item label="类型" prop="type">
        <el-radio-group v-model="form.type">
          <el-radio :label="1" border>菜品</el-radio>
          <el-radio :label="2" border>套餐</el-radio>
        </el-radio-group>
      </el-form-item>
      <el-form-item label="分店" prop="branchId">
        <el-select 
          v-model="form.branchId" 
          placeholder="请选择分店" 
          style="width: 100%"
          :disabled="!userStore.isAdmin && !!userStore.branchId"
        >
          <el-option
            v-for="branch in branchList"
            :key="branch.id"
            :label="branch.name"
            :value="branch.id"
          />
        </el-select>
      </el-form-item>
      <el-form-item label="排序" prop="sort">
        <el-input-number v-model="form.sort" :min="0" :max="999" controls-position="right" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-radio-group v-model="form.status">
          <el-radio :label="1" border>启用</el-radio>
          <el-radio :label="0" border>禁用</el-radio>
        </el-radio-group>
      </el-form-item>
    </el-form>
    <template #footer>
      <el-button icon="Close" @click="handleClose">取消</el-button>
      <el-button type="primary" icon="Check" :loading="loading" @click="handleSubmit">确定</el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, reactive, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { Close, Check } from '@element-plus/icons-vue'
import { saveCategory, updateCategory } from '@/api/category'
import { getBranchList } from '@/api/branch'
import { useUserStore } from '@/stores/user'

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false
  },
  formData: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue', 'success'])

const userStore = useUserStore()
const dialogVisible = ref(false)
const loading = ref(false)
const formRef = ref(null)
const branchList = ref([])

const form = reactive({
  id: undefined,
  name: '',
  type: 1,
  branchId: null,
  sort: 0,
  status: 1
})

const rules = {
  name: [{ required: true, message: '请输入分类名称', trigger: 'blur' }],
  type: [{ required: true, message: '请选择类型', trigger: 'change' }],
  branchId: [{ required: true, message: '请选择分店', trigger: 'change' }]
}

// 监听对话框显示
watch(() => props.modelValue, (val) => {
  dialogVisible.value = val
  if (val) {
    loadBranchList()
    if (props.formData.id) {
      Object.assign(form, props.formData)
    } else {
      resetForm()
      // 如果不是管理员且有分店ID，自动填充
      if (!userStore.isAdmin && userStore.branchId) {
        form.branchId = userStore.branchId
      }
    }
  }
})

// 监听对话框内部状态
watch(dialogVisible, (val) => {
  emit('update:modelValue', val)
})

// 加载分店列表
const loadBranchList = async () => {
  try {
    const res = await getBranchList({ pageNum: 1, pageSize: 1000 })
    if (res.code === 200) {
      branchList.value = res.data.list || []
    }
  } catch (error) {
    console.error('加载分店列表失败:', error)
  }
}

// 重置表单
const resetForm = () => {
  form.id = undefined
  form.name = ''
  form.type = 1
  form.branchId = null
  form.sort = 0
  form.status = 1
  formRef.value?.clearValidate()
}

// 提交
const handleSubmit = async () => {
  if (!formRef.value) return

  await formRef.value.validate(async (valid) => {
    if (valid) {
      loading.value = true
      try {
        if (form.id) {
          await updateCategory(form)
          ElMessage.success('修改成功')
        } else {
          await saveCategory(form)
          ElMessage.success('新增成功')
        }
        handleClose()
        emit('success')
      } catch (error) {
        console.error('保存失败:', error)
      } finally {
        loading.value = false
      }
    }
  })
}

// 关闭
const handleClose = () => {
  dialogVisible.value = false
  resetForm()
}
</script>

<style lang="scss" scoped>
.category-form {
  padding-right: 20px;
}
</style>


