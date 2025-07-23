<template>
    <div class="student-home">
      <div class="welcome-section">
        <h1>Welcome back, {{ userInfo.realName }}</h1>
      </div>
  
      <div class="class-section">
        <div class="section-header">
          <div class="header-tabs">
            <h2 class="tab active">My Classes</h2>
            <h2 class="tab" @click="goToAssignments">My Work</h2>
          </div>
          <div class="join-class">
            <input 
              type="text" 
              v-model="classCode" 
              placeholder="Enter class code"
              class="code-input"
            />
            <button class="join-btn" @click="joinClass">
              <i class="fas fa-plus"></i> Join Class
            </button>
          </div>
        </div>
  
        <div class="class-grid">
          <div v-if="loading" class="loading">Loading...</div>
          <div v-else-if="classes.length === 0" class="empty-state">
            <i class="fas fa-book-open empty-icon"></i>
            <p>You haven't joined any classes yet</p>
            <p class="empty-tip">Enter a class code to join a new class</p>
          </div>
          <div v-else class="class-cards">
            <div 
              v-for="classItem in classes" 
              :key="classItem.id" 
              class="class-card"
              @click="enterClass(classItem)"
            >
              <div class="card-header">
                <div class="class-info">
                  <h3 class="class-name">{{ classItem.name }}</h3>
                  <p class="teacher-name">{{ classItem.teacherName }}</p>
                </div>
                <div class="class-icon">
                  <i class="fas fa-book"></i>
                </div>
              </div>
              <div class="card-body">
                <div class="class-details">
                  <div class="detail-item">
                    <span class="label">班级代码:</span>
                    <span class="value">{{ classItem.code }}</span>
                  </div>
                  <div class="detail-item" v-if="classItem.description">
                    <span class="label">描述:</span>
                    <span class="value">{{ classItem.description }}</span>
                  </div>
                </div>
              </div>
              <div class="card-footer">
                <div class="assignment-count">
                  <i class="fas fa-file-alt"></i>
                  <span>点击查看作业</span>
                </div>
                <div class="enter-arrow">
                  <i class="fas fa-arrow-right"></i>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
  

    </div>
  </template>
  
  <script setup>
  import { ref, onMounted } from 'vue'
  import axios from 'axios'
import config from '@/config'
  import { ElMessageBox } from 'element-plus'
  import { useRouter } from 'vue-router'
  import 'element-plus/dist/index.css'
  
  const router = useRouter()
  const userInfo = ref({
    realName: localStorage.getItem('realName') || 'Student'
  })
  const classes = ref([])
  const loading = ref(true)
  const classCode = ref('')
  
  const fetchClasses = async () => {
    try {
      loading.value = true
      const response = await axios.get(`${config.baseUrl}/classes/student`, {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('token')}`
        }
      })
      classes.value = response.data
    } catch (error) {
      console.error('Failed to fetch classes:', error)
      await ElMessageBox.alert('Failed to fetch classes', 'Error', {
        confirmButtonText: 'OK',
        type: 'error'
      })
    } finally {
      loading.value = false
    }
  }
  
  const joinClass = async () => {
    if (!classCode.value) {
      await ElMessageBox.alert('Please enter a class code', 'Warning', {
        confirmButtonText: 'OK',
        type: 'warning'
      })
      return
    }
  
    try {
      const response = await axios.post(`${config.baseUrl}/classes/join`, 
        { code: classCode.value },
        {
          headers: {
            Authorization: `Bearer ${localStorage.getItem('token')}`
          }
        }
      )
      console.log("返回的数据为", response.data)
      if (!response.data) {
        await ElMessageBox.alert('Invalid class code', 'Error', {
          confirmButtonText: 'OK',
          type: 'error'
        })
        return
      }

      await ElMessageBox.alert('Successfully joined the class', 'Success', {
        confirmButtonText: 'OK',
        type: 'success'
      })
      classCode.value = ''
      await fetchClasses()
    } catch (error) {
      console.error('Failed to join class:', error)
      await ElMessageBox.alert('Invalid class code', 'Error', {
        confirmButtonText: 'OK',
        type: 'error'
      })
    }
  }
  
  const enterClass = (classItem) => {
    // Navigate to class-specific assignment view
    router.push({
      name: 'student-class',
      params: { classId: classItem.id },
      query: { className: classItem.name, teacherName: classItem.teacherName }
    })
  }
  
  const goToAssignments = () => {
    router.push('/student/assignments')
  }
  
  onMounted(fetchClasses)
  </script>
  
  <style scoped>
  .student-home {
    padding: 20px;
    max-width: 1600px;
    margin: 0 auto;
    margin-top: 100px;
  }
  
  .welcome-section {
    text-align: center;
    margin-bottom: 40px;
    padding: 30px;
    background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%);
    border-radius: 12px;
    color: white;
  }
  
  .welcome-section h1 {
    margin: 0;
    font-size: 2rem;
  }
  
  .welcome-section .subtitle {
    margin: 10px 0 0;
    opacity: 0.9;
  }
  
  .section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 30px;
    padding: 0 20px;
  }
  
  .header-tabs {
    display: flex;
    gap: 20px;
    align-items: center;
  }
  
  .tab {
    cursor: pointer;
    padding: 8px 16px;
    border-radius: 8px;
    transition: all 0.3s;
    color: #666;
  }
  
  .tab:hover {
    background: #f5f5f5;
  }
  
  .tab.active {
    color: #4CAF50;
    font-weight: bold;
  }
  
  .join-class {
    display: flex;
    gap: 10px;
  }
  
  .code-input {
    padding: 10px 15px;
    border: 1px solid #ddd;
    border-radius: 8px;
    font-size: 1rem;
    width: 200px;
  }
  
  .join-btn {
    padding: 10px 20px;
    background: #4CAF50;
    color: white;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 5px;
    font-weight: bold;
    transition: all 0.3s;
  }
  
  .join-btn:hover {
    background: #45a049;
  }
  
  .class-grid {
    width: 100%;
    padding: 0 20px;
  }
  
  .class-cards {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
    gap: 24px;
    padding: 20px 0;
  }
  
  .class-card {
    background: white;
    border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    cursor: pointer;
    transition: all 0.3s ease;
    overflow: hidden;
    border: 2px solid transparent;
  }
  
  .class-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
    border-color: #4CAF50;
  }
  
  .card-header {
    background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%);
    color: white;
    padding: 20px;
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
  }
  
  .class-info {
    flex: 1;
  }
  
  .class-name {
    margin: 0 0 8px 0;
    font-size: 1.4rem;
    font-weight: bold;
  }
  
  .teacher-name {
    margin: 0;
    font-size: 1rem;
    opacity: 0.9;
  }
  
  .class-icon {
    font-size: 2rem;
    opacity: 0.8;
  }
  
  .card-body {
    padding: 20px;
  }
  
  .class-details {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }
  
  .detail-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  
  .label {
    font-weight: 600;
    color: #666;
    font-size: 0.9rem;
  }
  
  .value {
    color: #333;
    font-weight: 500;
    background: #f5f5f5;
    padding: 4px 8px;
    border-radius: 4px;
    font-size: 0.9rem;
  }
  
  .card-footer {
    padding: 16px 20px;
    background: #f8f9fa;
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-top: 1px solid #eee;
  }
  
  .assignment-count {
    display: flex;
    align-items: center;
    gap: 8px;
    color: #666;
    font-size: 0.9rem;
  }
  
  .enter-arrow {
    color: #4CAF50;
    font-size: 1.2rem;
    transition: transform 0.3s ease;
  }
  
  .class-card:hover .enter-arrow {
    transform: translateX(4px);
  }
  
  .loading {
    text-align: center;
    padding: 20px;
    color: #666;
  }
  
  .empty-state {
    text-align: center;
    padding: 40px;
    color: #666;
    background: #f8f9fa;
    border-radius: 12px;
    grid-column: 1 / -1;
  }
  
  .empty-icon {
    font-size: 48px;
    color: #ddd;
    margin-bottom: 20px;
  }
  
  .empty-tip {
    color: #999;
    font-size: 0.9rem;
    margin-top: 10px;
  }
  </style>