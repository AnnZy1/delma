<template>
  <div class="header-container">
    <div class="header-left">
      <el-icon class="collapse-icon" @click="toggleSidebar">
        <Expand v-if="appStore.sidebarCollapsed" />
        <Fold v-else />
      </el-icon>
      <Breadcrumb />
    </div>
    <div class="header-right">
      <div class="header-icon-btn">
        <el-badge :value="3" class="item">
          <el-icon><Bell /></el-icon>
        </el-badge>
      </div>
      <el-dropdown @command="handleCommand" trigger="click">
        <div class="user-info">
          <el-avatar :size="32" :src="avatarUrl" />
          <span class="username">{{ userStore.name || userStore.username }}</span>
          <el-icon><CaretBottom /></el-icon>
        </div>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item command="profile">
              <el-icon><User /></el-icon>个人中心
            </el-dropdown-item>
            <el-dropdown-item divided command="logout">
              <el-icon><SwitchButton /></el-icon>退出登录
            </el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessageBox } from 'element-plus'
import { useUserStore } from '@/stores/user'
import { useAppStore } from '@/stores/app'
import { Bell, Expand, Fold, User, SwitchButton, CaretBottom } from '@element-plus/icons-vue'
import Breadcrumb from './Breadcrumb.vue'

const router = useRouter()
const userStore = useUserStore()
const appStore = useAppStore()

const avatarUrl = 'https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png'

const toggleSidebar = () => {
  appStore.toggleSidebar()
}

const handleCommand = async (command) => {
  if (command === 'logout') {
    try {
      await ElMessageBox.confirm('确定要退出登录吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      })
      await userStore.logout()
      router.push('/login')
    } catch (error) {
      // 用户取消
    }
  }
}
</script>

<style lang="scss" scoped>
@import '@/assets/styles/variables';

.header-container {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: $header-height;
  padding: 0 15px;
  background: $header-bg-color;
  box-shadow: 0 1px 4px rgba(0, 21, 41, 0.08);
  position: relative;
  z-index: 9;
}

.header-left {
  display: flex;
  align-items: center;

  .collapse-icon {
    font-size: 20px;
    cursor: pointer;
    color: #303133;
    margin-right: 15px;
    transition: color 0.3s;

    &:hover {
      color: $primary-color;
    }
  }
}

.header-right {
  display: flex;
  align-items: center;
  gap: 20px;

  .header-icon-btn {
    display: flex;
    align-items: center;
    cursor: pointer;
    padding: 0 8px;
    height: 100%;
    
    .el-icon {
      font-size: 20px;
      color: #5a5e66;
    }
    
    &:hover {
      .el-icon {
        color: $primary-color;
      }
    }
  }

  .user-info {
    display: flex;
    align-items: center;
    cursor: pointer;
    padding: 5px 8px;
    border-radius: 4px;
    transition: background 0.3s;

    &:hover {
      background: rgba(0,0,0,0.025);
    }

    .username {
      margin: 0 8px;
      font-size: 14px;
      color: #303133;
    }
    
    .el-icon {
      font-size: 12px;
      color: #909399;
    }
  }
}
</style>

