<template>
  <div class="auth-container">
    <div class="auth-box">
      <h1 class="auth-title">Sign Up</h1>
      <div class="auth-subtitle">Create your account to get started.</div>
      <form class="auth-form" @submit.prevent="handleSubmit">
        <label class="auth-label">Full Name</label>
        <input 
          class="auth-input" 
          type="text" 
          placeholder="Enter your full name" 
          v-model="formData.realName"
          required
        />
        <label class="auth-label">Email</label>
        <input 
          class="auth-input" 
          type="email" 
          placeholder="Enter your email" 
          v-model="formData.email"
          required
        />
        <label class="auth-label">Account Type</label>
        <select 
          class="auth-select" 
          v-model="formData.userType"
          required
        >
          <option value="STUDENT">Student</option>
          <option value="TEACHER">Teacher</option>
        </select>
        <label class="auth-label">Password</label>
        <input 
          class="auth-input" 
          type="password" 
          placeholder="Enter your password" 
          v-model="formData.password"
          required
          minlength="6"
        />
        <div class="auth-tip">Password must be at least 6 characters long.</div>
        <label class="auth-label">Confirm Password</label>
        <input 
          class="auth-input" 
          type="password" 
          placeholder="Confirm your password" 
          v-model="confirmPassword"
          required
        />
        <div v-if="error" class="error-message">{{ error }}</div>
        <div v-if="success" class="success-message">{{ success }}</div>
        <button class="auth-btn" type="submit" :disabled="loading">
          {{ loading ? 'Signing up...' : 'Sign up' }}
        </button>
      </form>
      <div class="auth-bottom">
        Already have an account? <a class="auth-link" href="/login">Log in</a>
        <div class="auth-note">
          Note: If you have made an account before and your credentials did not change, you will not recieve a verification email.
        </div>
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
const confirmPassword = ref('')

const formData = reactive({
  username: '',
  password: '',
  realName: '',
  email: '',
  userType: 'STUDENT'
})

const handleSubmit = async () => {
  try {
    // 重置错误信息
    error.value = ''
    success.value = ''
    
    // 验证密码
    if (formData.password !== confirmPassword.value) {
      error.value = 'Passwords do not match'
      return
    }

    // 设置用户名（使用邮箱作为用户名）
    formData.username = formData.email

    // 确保用户类型为大写
    formData.userType = formData.userType.toUpperCase()

    loading.value = true
    
    // 根据用户类型选择注册接口
    const endpoint = formData.userType === 'TEACHER' 
      ? `${config.baseUrl}/users/register/teacher`
      : `${config.baseUrl}/users/register/student`
    
    // 调用注册接口
    const response = await axios.post(endpoint, formData)
    
    // 显示成功消息
    const roleText = formData.userType === 'TEACHER' ? 'teacher' : 'student'
    success.value = `${roleText.charAt(0).toUpperCase() + roleText.slice(1)} account created successfully! Redirecting to login page...`
    
    // 3秒后跳转到登录页
    setTimeout(() => {
      router.push('/login')
    }, 3000)
  } catch (err) {
    error.value = err.response?.data?.error || 'Registration failed. Please try again.'
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
  color: #4b5563;
  font-size: 1rem;
  text-align: center;
  margin-bottom: 18px;
}
.auth-form {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.auth-label {
  font-size: 0.95rem;
  text-align: left;
  display: block;
  font-weight: bold;
}
.auth-input,
.auth-select {
  width: 100%;
  padding: 8px 10px;
  border: 1.5px solid #e5e7eb;
  border-radius: 8px;
  font-size: 0.98rem;
  margin-bottom: 0px;
  outline: none;
  transition: border 0.2s;
  background-color: white;
}
.auth-input:focus,
.auth-select:focus {
  border-color: #111;
}
.auth-select {
  cursor: pointer;
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
.auth-tip {
  color: #6b7280;
  font-size: 0.72rem;
  margin-bottom: 2px;
  margin-top: -10px;
  text-align: left;
}
.auth-note {
  color: #444;
  font-size: 0.92rem;
  margin-top: 8px;
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