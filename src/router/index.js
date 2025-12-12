import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '@/stores/user'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login/Login.vue'),
    meta: { title: '登录', requiresAuth: false }
  },
  {
    path: '/',
    component: () => import('@/components/Layout/AppLayout.vue'),
    redirect: '/dashboard',
    meta: { requiresAuth: true },
    children: [
      {   path: 'dashboard', 
          name: 'Dashboard',
          component: () => import('@/views/Dashboard/Dashboard.vue'),
          meta: {
              title: '数据看板', 
              icon: 'Odometer' }      },
        {   path: 'stat',
            name: 'Stat',
            component: () => import('@/views/Stat/BusinessStat.vue'),
            meta: { title: '经营统计', icon: 'TrendCharts' }      },
      {
        path: 'employee',
        name: 'Employee',
        component: () => import('@/views/Employee/EmployeeList.vue'),
        meta: { title: '员工管理', icon: 'User' }
      },
      {
        path: 'role',
        name: 'Role',
        component: () => import('@/views/Role/RoleList.vue'),
        meta: { title: '角色管理', icon: 'UserFilled' }
      },
      {
        path: 'branch',
        name: 'Branch',
        component: () => import('@/views/Branch/BranchList.vue'),
        meta: { title: '分店管理', icon: 'Shop' }
      },
      {
        path: 'category',
        name: 'Category',
        component: () => import('@/views/Category/CategoryList.vue'),
        meta: { title: '分类管理', icon: 'Folder' }
      },
      {
        path: 'dish',
        name: 'Dish',
        component: () => import('@/views/Dish/DishList.vue'),
        meta: { title: '菜品管理', icon: 'Food' }
      },
      {
        path: 'setmeal',
        name: 'Setmeal',
        component: () => import('@/views/Setmeal/SetmealList.vue'),
        meta: { title: '套餐管理', icon: 'Menu' }
      },
      {
        path: 'order',
        name: 'Order',
        component: () => import('@/views/Order/OrderList.vue'),
        meta: { title: '订单管理', icon: 'Document' }
      },
      {        path: 'log',        name: 'Log',        component: () => import('@/views/Log/LoginLog.vue'),        meta: { title: '操作日志', icon: 'List' }      }
    ]
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/dashboard'
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫
router.beforeEach((to, from, next) => {
  const userStore = useUserStore()
  
  // 设置页面标题
  document.title = to.meta.title ? `${to.meta.title} - 外卖管理系统` : '外卖管理系统'
  
  // 检查是否需要登录
  if (to.meta.requiresAuth !== false) {
    if (!userStore.isLoggedIn) {
      next({ path: '/login', query: { redirect: to.fullPath } })
      return
    }
  } else {
    // 如果已登录，访问登录页时重定向到首页
    if (to.path === '/login' && userStore.isLoggedIn) {
      next({ path: '/' })
      return
    }
  }
  
  next()
})

export default router

