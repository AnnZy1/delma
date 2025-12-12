<template>
  <el-dialog
    v-model="dialogVisible"
    :title="formData.id ? '编辑角色' : '新增角色'"
    width="600px"
    destroy-on-close
    :close-on-click-modal="false"
    @close="handleClose"
  >
    <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
      <el-form-item label="角色名称" prop="name">
        <el-input v-model="form.name" placeholder="请输入角色名称" />
      </el-form-item>
      <el-form-item label="描述" prop="description">
        <el-input
          v-model="form.description"
          type="textarea"
          :rows="3"
          placeholder="请输入角色描述"
        />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-radio-group v-model="form.status">
          <el-radio :label="1">启用</el-radio>
          <el-radio :label="0">禁用</el-radio>
        </el-radio-group>
      </el-form-item>
      <el-form-item label="权限" prop="permissionIds">
        <div class="permission-tree-container">
          <el-tree
            ref="treeRef"
            :data="permissionTree"
            :props="{ label: 'name', children: 'children' }"
            show-checkbox
            node-key="id"
            :default-checked-keys="form.permissionIds"
            @check="handleCheck"
          />
        </div>
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
import { saveRole, updateRole } from '@/api/role'
import { getPermissionTree } from '@/api/permission'

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
const treeRef = ref(null)
const permissionTree = ref([])

const form = reactive({
  name: '',
  description: '',
  status: 1,
  permissionIds: []
})

const rules = {
  name: [{ required: true, message: '请输入角色名称', trigger: 'blur' }],
  permissionIds: [{ required: true, message: '请选择权限', trigger: 'change' }]
}

// 监听对话框显示
watch(() => props.modelValue, (val) => {
  dialogVisible.value = val
  if (val) {
    loadPermissions()
    if (props.formData.id) {
      Object.assign(form, {
        ...props.formData,
        permissionIds: props.formData.permissionIds || []
      })
      // 确保树形控件回显选中状态
      // 注意：Element Plus Tree 回显需要设置 checked-keys，
      // 但如果父节点被选中，所有子节点也会被选中，所以回显时通常只需要叶子节点ID
      // 这里简化处理，直接用 permissionIds
    } else {
      resetForm()
    }
  }
})

// 监听对话框内部状态
watch(dialogVisible, (val) => {
  emit('update:modelValue', val)
})

// 加载权限树
const loadPermissions = async () => {
  try {
    const res = await getPermissionTree()
    if (res.code === 200) {
      permissionTree.value = res.data || []
    }
  } catch (error) {
    console.error('加载权限数据失败:', error)
  }
}

// 权限选择变化
const handleCheck = (data, checked) => {
  const checkedKeys = treeRef.value?.getCheckedKeys() || []
  const halfCheckedKeys = treeRef.value?.getHalfCheckedKeys() || []
  form.permissionIds = [...checkedKeys, ...halfCheckedKeys]
}

// 重置表单
const resetForm = () => {
  Object.assign(form, {
    name: '',
    description: '',
    status: 1,
    permissionIds: []
  })
  formRef.value?.clearValidate()
  treeRef.value?.setCheckedKeys([])
}

// 提交
const handleSubmit = async () => {
  if (!formRef.value) return

  await formRef.value.validate(async (valid) => {
    if (valid) {
      loading.value = true
      try {
        // 注意：这里提交的 permissionIds 是包含半选节点的
        if (form.id) {
          await updateRole(form)
          ElMessage.success('修改成功')
        } else {
          // 确保 permissionIds 是一个数组，即使为空
          form.permissionIds = form.permissionIds || []
          await saveRole(form)
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
.permission-tree-container {
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  padding: 10px;
  max-height: 300px;
  overflow-y: auto;
}
</style>
