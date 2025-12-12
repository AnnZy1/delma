<template>
  <el-dialog
    v-model="dialogVisible"
    :title="formData.id ? '编辑套餐' : '新增套餐'"
    width="800px"
    @close="handleClose"
  >
    <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
      <el-row :gutter="20">
        <el-col :span="12">
          <el-form-item label="套餐名称" prop="name">
            <el-input v-model="form.name" placeholder="请输入套餐名称" />
          </el-form-item>
        </el-col>
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
      </el-row>
      <el-row :gutter="20">
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
        <el-col :span="12">
          <el-form-item label="价格" prop="price">
            <el-input-number v-model="form.price" :min="0" :precision="2" style="width: 100%" />
          </el-form-item>
        </el-col>
      </el-row>
      <el-row :gutter="20">
        <el-col :span="12">
          <el-form-item label="状态" prop="status">
            <el-radio-group v-model="form.status">
              <el-radio :label="1">起售</el-radio>
              <el-radio :label="0">停售</el-radio>
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
          placeholder="请输入套餐描述"
        />
      </el-form-item>
      <el-form-item label="关联菜品">
        <el-button @click="handleAddDish">添加菜品</el-button>
        <div v-for="(dish, index) in form.setmealDishes" :key="index" class="dish-item">
          <el-select 
            v-model="dish.dishId" 
            placeholder="选择菜品" 
            style="width: 200px"
            @change="(val) => handleDishChange(val, index)"
          >
            <el-option
              v-for="d in dishList"
              :key="d.id"
              :label="d.name"
              :value="d.id"
            />
          </el-select>
          <el-input-number
            v-model="dish.copies"
            :min="1"
            placeholder="份数"
            style="width: 120px; margin-left: 10px"
          />
          <el-input-number
            v-model="dish.price"
            :min="0"
            :precision="2"
            placeholder="价格"
            style="width: 120px; margin-left: 10px"
          />
          <el-button link type="danger" @click="handleRemoveDish(index)">删除</el-button>
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
import { saveSetmeal, updateSetmeal } from '@/api/setmeal'
import { getCategoryList } from '@/api/category'
import { getDishList } from '@/api/dish'
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
const dishList = ref([])

const form = reactive({
  name: '',
  categoryId: null,
  branchId: null,
  price: 0,
  image: '',
  description: '',
  status: 1,
  setmealDishes: []
})

const rules = {
  name: [{ required: true, message: '请输入套餐名称', trigger: 'blur' }],
  categoryId: [{ required: true, message: '请选择分类', trigger: 'change' }],
  branchId: [{ required: true, message: '请选择分店', trigger: 'change' }],
  price: [{ required: true, message: '请输入价格', trigger: 'blur' }]
}

// 监听对话框显示
watch(() => props.modelValue, (val) => {
  dialogVisible.value = val
  if (val) {
    loadCategoryList()
    loadBranchList()
    loadDishList()
    if (props.formData.id) {
      Object.assign(form, {
        ...props.formData,
        setmealDishes: props.formData.setmealDishes || []
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

// 加载菜品列表
const loadDishList = async () => {
  try {
    const params = { pageNum: 1, pageSize: 1000, status: 1 }
    if (!userStore.isAdmin && userStore.branchId) {
      params.branchId = userStore.branchId
    }
    const res = await getDishList(params)
    if (res.code === 200) {
      dishList.value = res.data.list || []
    }
  } catch (error) {
    console.error('加载菜品列表失败:', error)
  }
}

// 添加菜品
const handleAddDish = () => {
  form.setmealDishes.push({ dishId: null, copies: 1, price: 0 })
}

// 菜品选择变化
const handleDishChange = (dishId, index) => {
  const selectedDish = dishList.value.find(item => item.id === dishId)
  if (selectedDish) {
    form.setmealDishes[index].price = selectedDish.price
  }
}

// 删除菜品
const handleRemoveDish = (index) => {
  form.setmealDishes.splice(index, 1)
}

// 重置表单
const resetForm = () => {
  Object.assign(form, {
    name: '',
    categoryId: null,
    branchId: null,
    price: 0,
    image: '',
    description: '',
    status: 1,
    setmealDishes: []
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
          await updateSetmeal(form)
          ElMessage.success('修改成功')
        } else {
          await saveSetmeal(form)
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
.dish-item {
  display: flex;
  align-items: center;
  margin-top: 10px;
}
</style>

