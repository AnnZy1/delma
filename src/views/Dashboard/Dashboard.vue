<template>
  <div class="app-container">
    <el-row :gutter="20">
      <el-col :span="6">
        <el-card class="stat-card" shadow="hover">
          <div class="stat-item">
            <div class="stat-icon" style="background: linear-gradient(135deg, #409eff, #36cfc9)">
              <el-icon><Document /></el-icon>
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ statData.orderCount || 0 }}</div>
              <div class="stat-label">今日订单</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card" shadow="hover">
          <div class="stat-item">
            <div class="stat-icon" style="background: linear-gradient(135deg, #67c23a, #95d475)">
              <el-icon><Money /></el-icon>
            </div>
            <div class="stat-content">
              <div class="stat-value">¥{{ statData.turnover || '0.00' }}</div>
              <div class="stat-label">今日营业额</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card" shadow="hover">
          <div class="stat-item">
            <div class="stat-icon" style="background: linear-gradient(135deg, #e6a23c, #f3d19e)">
              <el-icon><User /></el-icon>
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ employeeCount }}</div>
              <div class="stat-label">员工总数</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card" shadow="hover">
          <div class="stat-item">
            <div class="stat-icon" style="background: linear-gradient(135deg, #f56c6c, #fab6b6)">
              <el-icon><Shop /></el-icon>
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ branchCount }}</div>
              <div class="stat-label">分店总数</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" class="mt-20">
      <el-col :span="16">
        <el-card shadow="hover" class="h-full">
          <template #header>
            <div class="card-header">
              <span>快捷入口</span>
            </div>
          </template>
          <el-row :gutter="20" class="shortcut-list">
            <el-col :span="6" v-for="item in shortcuts" :key="item.path">
              <div class="shortcut-item" @click="$router.push(item.path)">
                <div class="icon-wrapper" :style="{ background: item.color }">
                  <el-icon><component :is="item.icon" /></el-icon>
                </div>
                <div class="label">{{ item.label }}</div>
              </div>
            </el-col>
          </el-row>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="hover" class="h-full">
          <template #header>
            <div class="card-header">
              <span>系统信息</span>
            </div>
          </template>
          <div class="system-info">
            <div class="info-item">
              <span class="label">当前用户：</span>
              <span class="value">{{ userStore.name || userStore.username }}</span>
            </div>
            <div class="info-item">
              <span class="label">所属角色：</span>
              <el-tag size="small">{{ userStore.roleName || '管理员' }}</el-tag>
            </div>
            <div class="info-item">
              <span class="label">当前时间：</span>
              <span class="value">{{ currentTime }}</span>
            </div>
            <el-divider />
            <div class="welcome-text">
              欢迎使用外卖管理系统，祝您工作愉快！
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { formatDateTime } from '@/utils/format'
import { getBusinessStat } from '@/api/stat'
import { getEmployeeList } from '@/api/employee'
import { getBranchList } from '@/api/branch'
import { Document, Money, User, Shop, Food, List, Setting } from '@element-plus/icons-vue'

const router = useRouter()
const userStore = useUserStore()
const currentTime = ref(formatDateTime(new Date()))
const timer = ref(null)

const statData = reactive({
  orderCount: 0,
  turnover: '0.00'
})
const employeeCount = ref(0)
const branchCount = ref(0)

const shortcuts = [
  { label: '订单管理', path: '/order', icon: 'List', color: '#409eff' },
  { label: '菜品管理', path: '/dish', icon: 'Food', color: '#67c23a' },
  { label: '套餐管理', path: '/setmeal', icon: 'Food', color: '#e6a23c' },
  { label: '员工管理', path: '/employee', icon: 'User', color: '#f56c6c' },
  { label: '数据统计', path: '/statistics', icon: 'Document', color: '#909399' },
  { label: '系统设置', path: '/role', icon: 'Setting', color: '#36cfc9' }
]

const loadData = async () => {
  try {
    const statRes = await getBusinessStat({ type: 'today' })
    if (statRes.code === 200) {
      statData.orderCount = statRes.data.orderCount
      statData.turnover = statRes.data.turnover || statRes.data.totalAmount
    }

    // 获取员工总数
    const empRes = await getEmployeeList({ pageNum: 1, pageSize: 1 })
    if (empRes.code === 200) {
      employeeCount.value = empRes.data.total
    }

    // 获取分店总数
    const branchRes = await getBranchList({ pageNum: 1, pageSize: 1 })
    if (branchRes.code === 200) {
      branchCount.value = branchRes.data.total
    }
  } catch (error) {
    console.error('加载首页数据失败:', error)
  }
}

onMounted(() => {
  loadData()
  timer.value = setInterval(() => {
    currentTime.value = formatDateTime(new Date())
  }, 1000)
})

onUnmounted(() => {
  if (timer.value) {
    clearInterval(timer.value)
  }
})
</script>

<style lang="scss" scoped>
.stat-card {
  transition: all 0.3s;
  
  &:hover {
    transform: translateY(-5px);
  }

  .stat-item {
    display: flex;
    align-items: center;

    .stat-icon {
      width: 60px;
      height: 60px;
      border-radius: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
      color: #fff;
      font-size: 28px;
      margin-right: 20px;
      box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
    }

    .stat-content {
      flex: 1;

      .stat-value {
        font-size: 28px;
        font-weight: bold;
        color: #303133;
        margin-bottom: 5px;
        font-family: 'DIN Alternate', sans-serif;
      }

      .stat-label {
        font-size: 14px;
        color: #909399;
      }
    }
  }
}

.shortcut-list {
  .shortcut-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 20px;
    cursor: pointer;
    border-radius: 8px;
    transition: all 0.3s;

    &:hover {
      background: #f5f7fa;
      
      .icon-wrapper {
        transform: scale(1.1);
      }
    }

    .icon-wrapper {
      width: 50px;
      height: 50px;
      border-radius: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
      color: #fff;
      font-size: 24px;
      margin-bottom: 10px;
      transition: all 0.3s;
      box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
    }

    .label {
      font-size: 14px;
      color: #606266;
    }
  }
}

.system-info {
  .info-item {
    display: flex;
    align-items: center;
    margin-bottom: 15px;
    
    .label {
      width: 80px;
      color: #909399;
    }
    
    .value {
      color: #303133;
      font-weight: 500;
    }
  }

  .welcome-text {
    color: #606266;
    line-height: 1.6;
    font-size: 14px;
  }
}

.h-full {
  height: 100%;
}
</style>
