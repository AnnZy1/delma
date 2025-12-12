<template>
  <div class="sidebar-container" :class="{ collapsed: appStore.sidebarCollapsed }">
    <div class="logo">

      <span v-if="!appStore.sidebarCollapsed" class="logo-text">Deliver Pro</span>
      <span v-else class="logo-text">D</span>
    </div>
    
    <el-scrollbar wrap-class="scrollbar-wrapper">
      <el-menu
        :default-active="activeMenu"
        :collapse="appStore.sidebarCollapsed"
        :unique-opened="true"
        :collapse-transition="false"
        router
        background-color="#304156"
        text-color="#bfcbd9"
        active-text-color="#409eff"
      >
        <div class="menu-group-title" v-if="!appStore.sidebarCollapsed">控制台</div>
        <el-menu-item index="/dashboard">
          <el-icon><Odometer /></el-icon>
          <template #title>数据看板</template>
        </el-menu-item>
        <el-menu-item index="/stat">
          <el-icon><TrendCharts /></el-icon>
          <template #title>经营统计</template>
        </el-menu-item>

        <div class="menu-group-title" v-if="!appStore.sidebarCollapsed">业务管理</div>
        <el-menu-item index="/order">
          <el-icon><List /></el-icon>
          <template #title>订单管理</template>
        </el-menu-item>
        <el-menu-item index="/dish">
          <el-icon><Food /></el-icon>
          <template #title>菜品管理</template>
        </el-menu-item>
        <el-menu-item index="/setmeal">
          <el-icon><KnifeFork /></el-icon>
          <template #title>套餐管理</template>
        </el-menu-item>
        <el-menu-item index="/category">
          <el-icon><Files /></el-icon>
          <template #title>分类管理</template>
        </el-menu-item>

        <div class="menu-group-title" v-if="!appStore.sidebarCollapsed">系统管理</div>
        <el-menu-item index="/branch">
          <el-icon><Shop /></el-icon>
          <template #title>分店管理</template>
        </el-menu-item>
        <el-menu-item index="/employee">
          <el-icon><User /></el-icon>
          <template #title>员工管理</template>
        </el-menu-item>
        <el-menu-item index="/role">
          <el-icon><Avatar /></el-icon>
          <template #title>角色管理</template>
        </el-menu-item>
      </el-menu>
    </el-scrollbar>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { useAppStore } from '@/stores/app'
import { 
  Odometer, 
  List, 
  Food, 
  KnifeFork, 
  Files, 
  Shop, 
  User, 
  Avatar, 
  TrendCharts 
} from '@element-plus/icons-vue'

const route = useRoute()
const appStore = useAppStore()

const activeMenu = computed(() => {
  const { path } = route
  // Handle nested routes if necessary
  return path
})
</script>

<style lang="scss" scoped>
@import '@/assets/styles/variables';

.sidebar-container {
  position: fixed;
  top: 0;
  left: 0;
  bottom: 0;
  width: $sidebar-width;
  height: 100vh;
  background-color: $sidebar-bg-color;
  transition: width 0.3s;
  box-shadow: 2px 0 6px rgba(0, 21, 41, 0.35);
  z-index: 1001;
  display: flex;
  flex-direction: column;

  &.collapsed {
    width: $sidebar-collapsed-width;
    
    .logo .logo-text {
      font-size: 20px;
    }
  }

  .logo {
    height: $header-height;
    display: flex;
    align-items: center;
    justify-content: center;
    background: #2b2f3a;
    overflow: hidden;
    flex-shrink: 0;
    
    .logo-text {
      color: #fff;
      font-weight: 600;
      font-size: 20px;
      white-space: nowrap;
      font-family: Avenir, Helvetica Neue, Arial, Helvetica, sans-serif;
    }
  }

  .menu-group-title {
    padding: 10px 20px;
    font-size: 12px;
    color: #909399;
    line-height: normal;
    margin-top: 10px;
  }
}

:deep(.el-scrollbar) {
  flex: 1;
  height: calc(100% - #{$header-height});
  
  .el-scrollbar__view {
    height: 100%;
  }
}

:deep(.el-menu) {
  border: none;
  width: 100%;
  
  .el-menu-item {
    &.is-active {
      background-color: $sidebar-active-text-color !important; // Use primary color as bg? No, maybe just text or subtle bg
      // Let's use Element's default active text color handling or custom
      background-color: #1890ff !important;
      color: #fff !important;
      
      &:hover {
        background-color: #40a9ff !important;
      }
    }
    
    &:hover {
      background-color: #263445 !important;
    }
    
    .el-icon {
      margin-right: 10px;
    }
  }
}
</style>

