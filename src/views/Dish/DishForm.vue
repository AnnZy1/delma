<template>
  <el-dialog
    v-model="dialogVisible"
    :title="formData.id ? '编辑菜品' : '新增菜品'"
    width="800px"
    @close="handleClose"
    destroy-on-close
    :close-on-click-modal="false"
  >
    <el-form ref="formRef" :model="form" :rules="rules" label-width="100px" class="dish-form">
      <el-row :gutter="20">
        <el-col :span="12">
          <el-form-item label="菜品名称" prop="name">
            <el-input v-model="form.name" placeholder="请输入菜品名称" />
          </el-form-item>
        </el-col>
        <el-col :span="12">
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
        </el-col>
      </el-row>
      <el-row :gutter="20">
        <el-col :span="12">
          <el-form-item label="分类" prop="categoryId">
            <el-select v-model="form.categoryId" placeholder="请选择分类" style="width: 100%">
              <el-option
                v-for="category in categoryList"
                :key="category.id"
                :label="category.name"
                :value="category.id"
              />
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="价格" prop="price">
            <el-input-number 
              v-model="form.price" 
              :min="0" 
              :precision="2" 
              :step="0.1"
              style="width: 100%" 
              controls-position="right"
            >
              <template #prefix>¥</template>
            </el-input-number>
          </el-form-item>
        </el-col>
      </el-row>
      <el-row :gutter="20">
        <el-col :span="12">
          <el-form-item label="状态" prop="status">
            <el-radio-group v-model="form.status">
              <el-radio :label="1" border>起售</el-radio>
              <el-radio :label="0" border>停售</el-radio>
            </el-radio-group>
          </el-form-item>
        </el-col>
      </el-row>
      
      <el-form-item label="图片" prop="image">
        <ImageUpload v-model="form.image" />
      </el-form-item>
      
      <el-form-item label="描述" prop="description">
        <el-input
          v-model="form.description"
          type="textarea"
          :rows="3"
          placeholder="请输入菜品描述（选填）"
          maxlength="200"
          show-word-limit
        />
      </el-form-item>
      
      <div class="flavor-section">
        <div class="flavor-header">
          <span class="label">口味配置</span>
          <el-button type="primary" link icon="Plus" @click="handleAddFlavor">添加口味</el-button>
        </div>
        
        <div v-if="form.flavors.length === 0" class="flavor-empty">
          暂无口味配置
        </div>
        
        <div v-else class="flavor-list">
          <div v-for="(flavor, index) in form.flavors" :key="index" class="flavor-item">
            <div class="flavor-index">#{{ index + 1 }}</div>
            <el-form-item 
              :prop="'flavors.' + index + '.name'"
              :rules="{ required: true, message: '请输入口味名称', trigger: 'blur' }"
              label-width="0"
              class="flavor-name"
            >
              <el-input v-model="flavor.name" placeholder="口味名称（如：辣度）" />
            </el-form-item>
            
            <el-form-item
              :prop="'flavors.' + index + '.value'"
              :rules="{ required: true, message: '请输入口味值', trigger: 'blur' }"
              label-width="0"
              class="flavor-value"
            >
              <el-input
                v-model="flavor.value"
                placeholder="口味值（如：微辣,中辣,重辣）"
              />
            </el-form-item>
            
            <el-button type="danger" link icon="Delete" @click="handleRemoveFlavor(index)">删除</el-button>
          </div>
        </div>
      </div>
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
import { Plus, Delete, Close, Check } from '@element-plus/icons-vue'
import { saveDish, updateDish } from '@/api/dish'
import { getCategoryList } from '@/api/category'
import { getBranchList } from '@/api/branch'
import { useUserStore } from '@/stores/user'
import ImageUpload from '@/components/Upload/ImageUpload.vue'

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
const categoryList = ref([])
const branchList = ref([])

const form = reactive({
  id: undefined,
  name: '',
  categoryId: null,
  branchId: null,
  price: 0,
  image: '',
  description: '',
  status: 1,
  flavors: []
})

const rules = {
  name: [{ required: true, message: '请输入菜品名称', trigger: 'blur' }],
  categoryId: [{ required: true, message: '请选择分类', trigger: 'change' }],
  branchId: [{ required: true, message: '请选择分店', trigger: 'change' }],
  price: [{ required: true, message: '请输入价格', trigger: 'blur' }],
  image: [{ required: true, message: '请上传图片', trigger: 'change' }]
}

// 监听对话框显示
watch(() => props.modelValue, (val) => {
  dialogVisible.value = val
  if (val) {
    loadCategoryList()
    loadBranchList()
    if (props.formData.id) {
      // 深拷贝，避免直接引用导致修改原数据
      const data = JSON.parse(JSON.stringify(props.formData))
      Object.assign(form, {
        ...data,
        flavors: data.flavors || []
      })
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

// 添加口味
const handleAddFlavor = () => {
  form.flavors.push({ name: '', value: '' })
}

// 删除口味
const handleRemoveFlavor = (index) => {
  form.flavors.splice(index, 1)
}

// 重置表单
const resetForm = () => {
  form.id = undefined
  form.name = ''
  form.categoryId = null
  form.price = 0
  form.image = ''
  form.description = ''
  form.status = 1
  form.flavors = []
  formRef.value?.clearValidate()
}

// 提交
const handleSubmit = async () => {
  if (!formRef.value) return

  await formRef.value.validate(async (valid) => {
    if (valid) {
      // 校验口味
      if (form.flavors.length > 0) {
        for (const flavor of form.flavors) {
          if (!flavor.name || !flavor.value) {
            ElMessage.warning('请完善口味信息')
            return
          }
        }
      }

      loading.value = true
      try {
        // 处理口味值的格式，如果是字符串数组可能需要转换，具体看后端需求
        // 假设后端接收 JSON 数组对象
        const submitData = { ...form }
        
        if (submitData.id) {
          await updateDish(submitData)
          ElMessage.success('修改成功')
        } else {
          await saveDish(submitData)
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
.dish-form {
  padding-right: 20px;
}

.flavor-section {
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  padding: 15px;
  margin-left: 30px; // 对应 label-width 留出的空间
  background-color: #f8f9fa;

  .flavor-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 10px;
    
    .label {
      font-weight: bold;
      color: #606266;
    }
  }
  
  .flavor-empty {
    text-align: center;
    color: #909399;
    padding: 20px 0;
    font-size: 13px;
  }

  .flavor-list {
    .flavor-item {
      display: flex;
      align-items: flex-start;
      margin-bottom: 15px;
      gap: 10px;
      
      &:last-child {
        margin-bottom: 0;
      }
      
      .flavor-index {
        width: 30px;
        line-height: 32px;
        color: #909399;
        font-size: 12px;
      }
      
      .flavor-name {
        width: 150px;
        margin-bottom: 0;
      }
      
      .flavor-value {
        flex: 1;
        margin-bottom: 0;
      }
    }
  }
}
</style>


