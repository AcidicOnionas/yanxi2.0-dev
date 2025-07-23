<template>
  <div class="auth-container">
    <div class="auth-box">
      <h1 class="auth-title">Log In</h1>
      <div class="auth-subtitle">Welcome back! Please enter your details.</div>
      <form class="auth-form" @submit.prevent="handleSubmit">
        <label class="auth-label">Email</label>
        <input 
          class="auth-input" 
          type="email" 
          placeholder="Enter your email" 
          v-model="formData.username"
          required
        />
        <div class="auth-label-row">
          <label class="auth-label">Password</label>
          <!-- <a class="auth-link" href="#">Forgot password?</a> -->
        </div>
        <input 
          class="auth-input" 
          type="password" 
          placeholder="Enter your password" 
          v-model="formData.password"
          required
        />
        <div v-if="error" class="error-message">{{ error }}</div>
        <div v-if="success" class="success-message">{{ success }}</div>
        <button class="auth-btn" type="submit" :disabled="loading">
          {{ loading ? 'Logging in...' : 'Log in' }}
        </button>
      </form>
      <div class="auth-bottom">
        Don't have an account? <a class="auth-link" href="/signup">Sign up</a>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'
import config from '@/config'

const router = useRouter()
const loading = ref(false)
const error = ref('')
const success = ref('')

const formData = reactive({
  username: '',
  password: '',
  userType: 'STUDENT' // 默认学生登录
})

const handleSubmit = async () => {
  try {
    // 重置错误信息
    error.value = ''
    success.value = ''
    
    loading.value = true
    
    // 调用登录接口
            const response = await axios.post(`${config.baseUrl}/users/login`, formData)
    
    // 保存token和userRole到localStorage
    localStorage.setItem('token', response.data.token)
    localStorage.setItem('userRole', response.data.userRole)
    localStorage.setItem('realName', response.data.realName)
    
    // 显示成功消息
    success.value = 'Login successful! Redirecting...'
    
    // 根据身份跳转
    setTimeout(() => {
      if (response.data.userRole && response.data.userRole.toUpperCase() === 'TEACHER') {
        router.push('/teacher')
      } else {
        router.push('/student/home')
      }
      // Trigger a storage event to update navigation
      window.dispatchEvent(new Event('storage'))
    }, 1500)
  } catch (err) {
    error.value = err.response?.data?.error || 'Login failed. Please try again.'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.auth-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #fff;
}
.auth-box {
  background: #fff;
  border-radius: 18px;
  box-shadow: 0 4px 24px rgba(0,0,0,0.07);
  padding: 32px 20px 20px 20px;
  width: 380px;
  max-width: 95vw;
  display: flex;
  flex-direction: column;
  align-items: center;
}
.auth-title {
  font-size: 1.6rem;
  font-weight: bold;
  text-align: center;
  margin-bottom: 10px;
}
.auth-subtitle {
  font-size: 1rem;
  margin-bottom: 18px;
  white-space: nowrap;
  width: max-content;
  max-width: 100%;
  overflow-x: auto;
  text-align: center;
  margin-left: auto;
  margin-right: auto;
}
.auth-form {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 10px;
  align-items: stretch;
}
.auth-label {
  font-size: 0.95rem;
  text-align: left;
  display: block;
  font-weight: bold;
}
.auth-label-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0px;
}
.auth-label-row .auth-label {
  flex: 1;
  text-align: left;
  display: block;
}
.auth-input {
  width: 100%;
  padding: 8px 10px;
  border: 1.5px solid #e5e7eb;
  border-radius: 8px;
  font-size: 0.98rem;
  margin-bottom: 0px;
  outline: none;
  transition: border 0.2s;
}
.auth-input:focus {
  border-color: #111;
}
.auth-btn {
  width: 100%;
  background: #111;
  color: #fff;
  border: none;
  border-radius: 8px;
  padding: 10px 0;
  font-size: 1rem;
  font-weight: bold;
  margin-top: 6px;
  cursor: pointer;
  transition: background 0.2s;
}
.auth-btn:hover {
  background: #333;
}
.auth-bottom {
  margin-top: 14px;
  color: #4b5563;
  font-size: 0.95rem;
  text-align: center;
}
.auth-link {
  color: #111;
  font-weight: bold;
  text-decoration: none;
  margin-left: 2px;
  font-size: 0.98rem;
}
.auth-link:hover {
  text-decoration: underline;
}
.error-message {
  color: #dc2626;
  font-size: 0.9rem;
  margin-top: 8px;
  text-align: center;
}
.success-message {
  color: #059669;
  font-size: 0.9rem;
  margin-top: 8px;
  text-align: center;
  background-color: #ecfdf5;
  padding: 8px;
  border-radius: 4px;
  border: 1px solid #10b981;
}
</style> 