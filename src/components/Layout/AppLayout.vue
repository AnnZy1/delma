<template>
  <div class="app-layout">
    <Sidebar />
    <div class="main-container" :class="{ 'sidebar-collapsed': appStore.sidebarCollapsed }">
      <Header />
      <div class="app-main">
        <div class="content-wrapper">
          <router-view v-slot="{ Component }">
            <transition name="fade-transform" mode="out-in">
              <component :is="Component" />
            </transition>
          </router-view>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useAppStore } from '@/stores/app'
import Sidebar from './Sidebar.vue'
import Header from './Header.vue'

const appStore = useAppStore()
</script>

<style lang="scss" scoped>
@use '@/assets/styles/variables' as *;
.app-layout {
  display: flex;
  height: 100vh;
  overflow: hidden;
}

.main-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  margin-left: $sidebar-width;
  transition: margin-left 0.3s;
  width: calc(100% - $sidebar-width);

  &.sidebar-collapsed {
    margin-left: $sidebar-collapsed-width;
    width: calc(100% - $sidebar-collapsed-width);
  }
}

.app-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  background: $bg-color-page;
}

.content-wrapper {
  flex: 1;
  padding: $content-padding;
  overflow-y: auto;
}

// 页面切换动画
.fade-transform-leave-active,
.fade-transform-enter-active {
  transition: all 0.3s;
}

.fade-transform-enter-from {
  opacity: 0;
  transform: translateX(-30px);
}

.fade-transform-leave-to {
  opacity: 0;
  transform: translateX(30px);
}
</style>

