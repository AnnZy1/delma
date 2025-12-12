<template>
  <el-dialog
    v-model="dialogVisible"
    :title="formData.id ? '编辑员工' : '新增员工'"
    width="600px"
    @close="handleClose"
  >
    <el-form
      ref="formRef"
      :model="form"
      :rules="rules"
      label-width="100px"
    >
      <el-form-item label="用户名" prop="username">
        <el-input v-model="form.username" placeholder="请输入用户名" :disabled="!!formData.id" />
      </el-form-item>
      <el-form-item label="姓名" prop="name">
        <el-input v-model="form.name" placeholder="请输入姓名" />
      </el-form-item>
      <el-form-item label="手机号" prop="phone">
        <el-input v-model="form.phone" placeholder="请输入手机号" />
      </el-form-item>
      <el-form-item label="性别" prop="sex">
        <el-radio-group v-model="form.sex">
          <el-radio label="男">男</el-radio>
          <el-radio label="女">女</el-radio>
        </el-radio-group>
      </el-form-item>
      <el-form-item label="身份证号" prop="idNumber">
        <el-input v-model="form.idNumber" placeholder="请输入身份证号" />
      </el-form-item>
      <el-form-item label="角色" prop="roleId">
        <el-select v-model="form.roleId" placeholder="请选择角色" style="width: 100%">
          <el-option
            v-for="role in roleList"
            :key="role.id"
            :label="role.name"
            :value="role.id"
          />
        </el-select>
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
      <el-form-item label="状态" prop="status">
        <el-radio-group v-model="form.status">
          <el-radio :label="1">正常</el-radio>
          <el-radio :label="0">锁定</el-radio>
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
import { saveEmployee, updateEmployee } from '@/api/employee'
import { getRoleList } from '@/api/role'
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
const roleList = ref([])
const branchList = ref([])

const form = reactive({
  username: '',
  name: '',
  phone: '',
  sex: '未知',
  idNumber: '',
  roleId: null,
  branchId: null,
  status: 1
})

const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  name: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ],
  roleId: [{ required: true, message: '请选择角色', trigger: 'change' }],
  branchId: [{ required: true, message: '请选择分店', trigger: 'change' }]
}

// 监听对话框显示
watch(() => props.modelValue, (val) => {
  dialogVisible.value = val
  if (val) {
    loadRoleList()
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

// 加载角色列表
const loadRoleList = async () => {
  try {
    const res = await getRoleList({ pageNum: 1, pageSize: 1000 })
    if (res.code === 200) {
      roleList.value = res.data.list || []
    }
  } catch (error) {
    console.error('加载角色列表失败:', error)
  }
}

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
  Object.assign(form, {
    username: '',
    name: '',
    phone: '',
    sex: '男',
    idNumber: '',
    roleId: null,
    branchId: null,
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
          await updateEmployee(form)
          ElMessage.success('修改成功')
        } else {
          await saveEmployee(form)
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

