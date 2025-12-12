import { defineStore } from 'pinia'
import { getToken, setToken, removeToken, getUserInfo, setUserInfo, removeUserInfo } from '@/utils/auth'
import { login, logout } from '@/api/auth'

export const useUserStore = defineStore('user', {
  state: () => ({
    token: getToken() || '',
    userInfo: getUserInfo() || null
  }),

  getters: {
    isLoggedIn: (state) => !!state.token,
    username: (state) => state.userInfo?.username || '',
    name: (state) => state.userInfo?.name || '',
    roleId: (state) => state.userInfo?.roleId || null,
    roleName: (state) => state.userInfo?.roleName || '',
    branchId: (state) => state.userInfo?.branchId || null,
    branchName: (state) => state.userInfo?.branchName || '',
    permissions: (state) => state.userInfo?.permissions || [],
    isAdmin: (state) => state.userInfo?.roleName === '管理员'
  },

  actions: {
    // 登录
    async login(loginForm) {
      try {
        const res = await login(loginForm)
        if (res.code === 200) {
          const { token, userInfo } = res.data
          this.token = token
          this.userInfo = userInfo
          setToken(token)
          setUserInfo(userInfo)
          return Promise.resolve(res)
        } else {
          return Promise.reject(new Error(res.msg))
        }
      } catch (error) {
        return Promise.reject(error)
      }
    },

    // 退出登录
    async logout() {
      try {
        await logout()
      } catch (error) {
        console.error('退出登录失败:', error)
      } finally {
        this.token = ''
        this.userInfo = null
        removeToken()
        removeUserInfo()
      }
    },

    // 更新用户信息
    updateUserInfo(userInfo) {
      this.userInfo = userInfo
      setUserInfo(userInfo)
    }
  }
})

