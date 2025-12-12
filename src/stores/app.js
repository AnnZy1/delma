import { defineStore } from 'pinia'

export const useAppStore = defineStore('app', {
  state: () => ({
    sidebarCollapsed: false, // 侧边栏是否折叠
    device: 'desktop' // 设备类型
  }),

  actions: {
    // 切换侧边栏折叠状态
    toggleSidebar() {
      this.sidebarCollapsed = !this.sidebarCollapsed
    },

    // 设置侧边栏折叠状态
    setSidebarCollapsed(collapsed) {
      this.sidebarCollapsed = collapsed
    },

    // 设置设备类型
    setDevice(device) {
      this.device = device
    }
  }
})

