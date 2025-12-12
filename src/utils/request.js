import axios from 'axios'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/stores/user'
import router from '@/router'
import NProgress from 'nprogress'
import 'nprogress/nprogress.css'

// 配置NProgress
NProgress.configure({ showSpinner: false })

// 创建axios实例
const service = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || '/api',
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json;charset=UTF-8'
  }
})

// 请求拦截器
service.interceptors.request.use(
  (config) => {
    NProgress.start()
    const userStore = useUserStore()
    const token = userStore.token
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => {
    NProgress.done()
    return Promise.reject(error)
  }
)

// 响应拦截器
service.interceptors.response.use(
  (response) => {
    NProgress.done()
    // 导出等二进制响应直接返回原始响应，交由调用方处理
    if (response.config && response.config.responseType === 'blob') {
      return response
    }

    const res = response.data

    if (res && res.code === 200) {
      return res
    }

    ElMessage.error(res?.msg || '请求失败')
    return Promise.reject(new Error(res?.msg || '请求失败'))
  },
  (error) => {
    NProgress.done()
    console.error('请求错误:', error)

    if (error.response) {
      const { status, data } = error.response

      switch (status) {
        case 401:
          ElMessage.error('未登录或登录已过期，请重新登录')
          const userStore = useUserStore()
          userStore.logout()
          router.push('/login')
          break
        case 403:
          ElMessage.error('没有权限访问该资源')
          break
        case 404:
          ElMessage.error('请求的资源不存在')
          break
        case 500:
          ElMessage.error(data?.msg || '服务器内部错误')
          break
        default:
          ElMessage.error(data?.msg || `请求失败: ${status}`)
      }
    } else if (error.request) {
      ElMessage.error('网络连接失败，请检查网络')
    } else {
      ElMessage.error(error.message || '请求配置错误')
    }

    return Promise.reject(error)
  }
)

export default service
