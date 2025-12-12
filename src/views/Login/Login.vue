<template>
  <div class="login-container">
    <div class="login-left">
      <div class="brand-info">
        <h1>Deliver Pro</h1>
        <p class="subtitle">新一代外卖业务全流程管理系统</p>
        <div class="features">
          <div class="feature-item">
            <el-icon><DataLine /></el-icon>
            <span>实时数据监控</span>
          </div>
          <div class="feature-item">
            <el-icon><Goods /></el-icon>
            <span>智能菜品管理</span>
          </div>
          <div class="feature-item">
            <el-icon><List /></el-icon>
            <span>高效订单处理</span>
          </div>
        </div>
      </div>
      <div class="glass-effect"></div>
    </div>
    
    <div class="login-right">
      <div class="login-box">
        <div class="login-header">
          <h2>欢迎登录</h2>
          <p>请输入您的管理员账号</p>
        </div>
        
        <el-form
          ref="loginFormRef"
          :model="loginForm"
          :rules="loginRules"
          class="login-form"
          size="large"
          @submit.prevent="handleLogin"
        >
          <el-form-item prop="username">
            <el-input
              v-model="loginForm.username"
              placeholder="用户名"
              prefix-icon="User"
              clearable
            />
          </el-form-item>
          
          <el-form-item prop="password">
            <el-input
              v-model="loginForm.password"
              type="password"
              placeholder="密码"
              prefix-icon="Lock"
              show-password
              @keyup.enter="handleLogin"
            />
          </el-form-item>
          
          <el-form-item>
            <el-button
              type="primary"
              class="login-button"
              :loading="loading"
              @click="handleLogin"
            >
              登 录
            </el-button>
          </el-form-item>
        </el-form>
        
        <div class="login-footer">
          <el-tag type="info" size="small">默认账号：admin / 123456</el-tag>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { User, Lock, DataLine, Goods, List } from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const loginFormRef = ref(null)
const loading = ref(false)

const loginForm = reactive({
  username: 'admin',
  password: '123456'
})

const loginRules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

const handleLogin = async () => {
  if (!loginFormRef.value) return

  await loginFormRef.value.validate(async (valid) => {
    if (valid) {
      loading.value = true
      try {
        await userStore.login(loginForm)
        ElMessage.success('登录成功')
        const redirect = route.query.redirect || '/'
        router.push(redirect)
      } catch (error) {
        ElMessage.error(error.message || '登录失败')
      } finally {
        loading.value = false
      }
    }
  })
}
</script>

<style lang="scss" scoped>
.login-container {
  display: flex;
  width: 100%;
  height: 100vh;
  background: #fff;
  overflow: hidden;

  .login-left {
    flex: 1;
    background: linear-gradient(135deg, #1890ff 0%, #36cfc9 100%);
    position: relative;
    display: flex;
    flex-direction: column;
    justify-content: center;
    padding: 0 80px;
    color: #fff;
    
    .brand-info {
      position: relative;
      z-index: 2;
      
      h1 {
        font-size: 48px;
        font-weight: bold;
        margin-bottom: 20px;
        letter-spacing: 2px;
      }
      
      .subtitle {
        font-size: 24px;
        opacity: 0.9;
        margin-bottom: 60px;
        font-weight: 300;
      }
      
      .features {
        display: flex;
        gap: 30px;
        
        .feature-item {
          display: flex;
          flex-direction: column;
          align-items: center;
          gap: 10px;
          background: rgba(255, 255, 255, 0.1);
          padding: 20px;
          border-radius: 12px;
          backdrop-filter: blur(10px);
          transition: transform 0.3s;
          
          &:hover {
            transform: translateY(-5px);
            background: rgba(255, 255, 255, 0.2);
          }
          
          .el-icon {
            font-size: 32px;
          }
          
          span {
            font-size: 14px;
          }
        }
      }
    }
    
    .glass-effect {
      position: absolute;
      top: -50%;
      right: -20%;
      width: 100%;
      height: 200%;
      background: linear-gradient(to bottom left, rgba(255,255,255,0.1), transparent);
      transform: rotate(-15deg);
      pointer-events: none;
    }
  }

  .login-right {
    width: 500px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: #fff;
    
    .login-box {
      width: 100%;
      max-width: 380px;
      padding: 0 20px;
      
      .login-header {
        margin-bottom: 40px;
        
        h2 {
          font-size: 32px;
          font-weight: 600;
          color: #1f2937;
          margin-bottom: 12px;
        }
        
        p {
          color: #6b7280;
          font-size: 16px;
        }
      }
      
      .login-form {
        .el-input {
          --el-input-height: 48px;
          
          :deep(.el-input__wrapper) {
            background-color: #f3f4f6;
            box-shadow: none;
            border-radius: 8px;
            
            &.is-focus {
              background-color: #fff;
              box-shadow: 0 0 0 2px var(--el-color-primary);
            }
          }
        }
        
        .login-button {
          width: 100%;
          height: 48px;
          font-size: 16px;
          font-weight: 600;
          border-radius: 8px;
          margin-top: 10px;
          box-shadow: 0 4px 14px 0 rgba(64, 158, 255, 0.39);
          
          &:hover {
            box-shadow: 0 6px 20px rgba(64, 158, 255, 0.23);
            transform: translateY(-1px);
          }
        }
      }
      
      .login-footer {
        margin-top: 30px;
        text-align: center;
      }
    }
  }
}

@media (max-width: 992px) {
  .login-container {
    .login-left {
      display: none;
    }
    
    .login-right {
      width: 100%;
      background: url('https://assets.qlife.co.jp/articles/46963/46963_01.jpg') no-repeat center/cover;
      position: relative;
      
      &::before {
        content: '';
        position: absolute;
        inset: 0;
        background: rgba(255,255,255,0.9);
        backdrop-filter: blur(5px);
      }
      
      .login-box {
        position: relative;
        z-index: 1;
        background: rgba(255,255,255,0.9);
        padding: 40px;
        border-radius: 16px;
        box-shadow: 0 20px 40px rgba(0,0,0,0.1);
      }
    }
  }
}
</style>

