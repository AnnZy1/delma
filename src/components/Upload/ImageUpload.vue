<template>
  <div class="image-upload">
    <el-upload
      :action="uploadUrl"
      :headers="uploadHeaders"
      :on-success="handleSuccess"
      :on-error="handleError"
      :before-upload="beforeUpload"
      :show-file-list="false"
      :disabled="disabled"
    >
      <img v-if="imageUrl" :src="imageUrl" class="uploaded-image" />
      <el-icon v-else class="upload-icon"><Plus /></el-icon>
    </el-upload>
    <div v-if="imageUrl" class="image-actions">
      <el-button link type="danger" @click="handleRemove">删除</el-button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { uploadImage } from '@/api/common'
import { useUserStore } from '@/stores/user'

const props = defineProps({
  modelValue: {
    type: String,
    default: ''
  },
  disabled: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['update:modelValue'])

const userStore = useUserStore()
const imageUrl = computed({
  get: () => {
    const val = props.modelValue
    if (val && !val.startsWith('http') && !val.startsWith('/') && !val.startsWith('data:')) {
      return `${API_BASE_URL}/admin/common/download?name=${val}`
    }
    return val
  },
  set: (val) => emit('update:modelValue', val)
})

import { API_BASE_URL } from '@/env'

const uploadUrl = computed(() => {
  return `${API_BASE_URL}/admin/common/upload`
})

const uploadHeaders = computed(() => {
  return {
    Authorization: `Bearer ${userStore.token}`
  }
})

const beforeUpload = (file) => {
  const isImage = file.type.startsWith('image/')
  const isLt5M = file.size / 1024 / 1024 < 5

  if (!isImage) {
    ElMessage.error('只能上传图片文件!')
    return false
  }
  if (!isLt5M) {
    ElMessage.error('图片大小不能超过 5MB!')
    return false
  }
  return true
}

const handleSuccess = (response) => {
  if (response.code === 200) {
    let url = response.data.url || response.data
    // 如果返回的是相对路径或文件名，拼接完整路径
    if (url && !url.startsWith('http') && !url.startsWith('/') && !url.startsWith('data:')) {
      url = `${API_BASE_URL}/admin/common/download?name=${url}`
    }
    imageUrl.value = url
    ElMessage.success('上传成功')
  } else {
    ElMessage.error(response.msg || '上传失败')
  }
}

const handleError = () => {
  ElMessage.error('上传失败')
}

const handleRemove = () => {
  imageUrl.value = ''
}
</script>

<style lang="scss" scoped>
.image-upload {
  .uploaded-image {
    width: 150px;
    height: 150px;
    object-fit: cover;
    border-radius: 4px;
    cursor: pointer;
  }

  .upload-icon {
    width: 150px;
    height: 150px;
    font-size: 28px;
    color: #8c939d;
    border: 1px dashed #d9d9d9;
    border-radius: 4px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: border-color 0.3s;

    &:hover {
      border-color: #409eff;
    }
  }

  .image-actions {
    margin-top: 10px;
  }
}
</style>

