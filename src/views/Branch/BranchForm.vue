<template>
  <el-dialog
    v-model="dialogVisible"
    :title="formData.id ? '编辑分店' : '新增分店'"
    width="600px"
    destroy-on-close
    :close-on-click-modal="false"
    @close="handleClose"
  >
    <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
      <el-form-item label="分店名称" prop="name">
        <el-input v-model="form.name" placeholder="请输入分店名称" />
      </el-form-item>
      <el-form-item label="详细地址" prop="address">
        <el-input v-model="form.address" type="textarea" :rows="2" placeholder="请输入详细地址" />
      </el-form-item>
      <el-form-item label="联系人" prop="contactName">
        <el-input v-model="form.contactName" placeholder="请输入联系人" />
      </el-form-item>
      <el-form-item label="联系电话" prop="contactPhone">
        <el-input v-model="form.contactPhone" placeholder="请输入联系电话" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-radio-group v-model="form.status">
          <el-radio :label="1">启用</el-radio>
          <el-radio :label="0">禁用</el-radio>
        </el-radio-group>
      </el-form-item>
    </el-form>
    <template #footer>
      <el-button @click="handleClose">取消</el-button>
      <el-button type="primary" :loading="loading" @click="handleSubmit">确定</el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, reactive, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { saveBranch, updateBranch } from '@/api/branch'

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

const dialogVisible = ref(false)
const loading = ref(false)
const formRef = ref(null)

const form = reactive({
  name: '',
  address: '',
  contactName: '',
  contactPhone: '',
  status: 1
})

const rules = {
  name: [{ required: true, message: '请输入分店名称', trigger: 'blur' }],
  address: [{ required: true, message: '请输入详细地址', trigger: 'blur' }],
  contactName: [{ required: true, message: '请输入联系人', trigger: 'blur' }],
  contactPhone: [
    { required: true, message: '请输入联系电话', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ]
}

// 监听对话框显示
watch(() => props.modelValue, (val) => {
  dialogVisible.value = val
  if (val) {
    if (props.formData.id) {
      Object.assign(form, props.formData)
    } else {
      resetForm()
    }
  }
})

// 监听对话框内部状态
watch(dialogVisible, (val) => {
  emit('update:modelValue', val)
})

// 重置表单
const resetForm = () => {
  Object.assign(form, {
    name: '',
    address: '',
    contactName: '',
    contactPhone: '',
    status: 1
  })
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
          await updateBranch(form)
          ElMessage.success('修改成功')
        } else {
          await saveBranch(form)
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

