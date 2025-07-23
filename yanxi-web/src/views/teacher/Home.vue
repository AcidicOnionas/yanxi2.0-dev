<template>
  <div class="teacher-home">
    <div class="welcome-section">
      <h1>Welcome back, {{ userInfo.realName }}</h1>
      <p class="subtitle">Manage your classes and assignments</p>
    </div>

    <div class="class-section">
      <div class="section-header">
        <div class="header-tabs">
          <h2 class="tab active">My Classes</h2>
        </div>
        <div class="create-class">
          <button class="create-btn" @click="showAddClassModal = true">
            <i class="fas fa-plus"></i> Create Class
          </button>
        </div>
      </div>

      <div class="class-grid">
        <div v-if="loading" class="loading">Loading...</div>
        <div v-else-if="classes.length === 0" class="empty-state">
          <i class="fas fa-chalkboard-teacher empty-icon"></i>
          <p>You haven't created any classes yet</p>
          <p class="empty-tip">Create your first class to get started</p>
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
                <p class="class-code">Code: {{ classItem.code }}</p>
              </div>
              <div class="card-actions">
                <button 
                  class="delete-btn" 
                  @click.stop="deleteClass(classItem)"
                  title="Delete Class"
                >
                  <i class="fas fa-trash"></i>
                </button>
                <div class="class-icon">
                  <i class="fas fa-chalkboard-teacher"></i>
                </div>
              </div>
            </div>
            <div class="card-body">
              <div class="class-details">
                <div class="detail-item" v-if="classItem.description">
                  <span class="label">Description:</span>
                  <span class="value">{{ classItem.description }}</span>
                </div>
                <div class="detail-item">
                  <span class="label">Students:</span>
                  <span class="value">{{ classItem.studentCount || 0 }} enrolled</span>
                </div>
              </div>
            </div>
            <div class="card-footer">
              <div class="assignment-count">
                <i class="fas fa-file-alt"></i>
                <span>Manage assignments & students</span>
              </div>
              <div class="enter-arrow">
                <i class="fas fa-arrow-right"></i>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Add Class Modal -->
    <div v-if="showAddClassModal" class="modal">
      <div class="modal-content">
        <h3>Create New Class</h3>
        <form @submit.prevent="handleSubmit">
          <div class="form-group">
            <label>Class Name</label>
            <input 
              type="text" 
              v-model="classForm.name" 
              required 
              placeholder="Enter class name"
            >
          </div>
          <div class="form-group">
            <label>Description</label>
            <textarea 
              v-model="classForm.description" 
              placeholder="Enter class description"
              rows="3"
            ></textarea>
          </div>
          <div class="modal-actions">
            <button type="button" class="cancel-btn" @click="closeModal">Cancel</button>
            <button type="submit" class="submit-btn">Create Class</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'
import config from '@/config'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useRouter } from 'vue-router'
import 'element-plus/dist/index.css'

const router = useRouter()
const userInfo = ref({
  realName: localStorage.getItem('realName') || 'Teacher'
})
const classes = ref([])
const loading = ref(true)
const showAddClassModal = ref(false)

const classForm = ref({
  name: '',
  description: ''
})

const fetchClasses = async () => {
  try {
    loading.value = true
    const response = await axios.get(`${config.baseUrl}/classes/teacher`, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem('token')}`
      }
    })
    classes.value = response.data
  } catch (error) {
    console.error('Failed to fetch classes:', error)
    // Set empty array if API fails
    classes.value = []
  } finally {
    loading.value = false
  }
}

const handleSubmit = async () => {
  try {
    const response = await axios.post(`${config.baseUrl}/classes`, classForm.value, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem('token')}`
      }
    })
    
    ElMessage.success('Class created successfully')
    closeModal()
    await fetchClasses()
  } catch (error) {
    console.error('Failed to create class:', error)
    ElMessage.error('Failed to create class')
  }
}

const closeModal = () => {
  showAddClassModal.value = false
  classForm.value = {
    name: '',
    description: ''
  }
}

const deleteClass = async (classItem) => {
  try {
    await ElMessageBox.confirm(
      `Are you sure you want to delete "${classItem.name}"? This action cannot be undone and will remove all assignments and student enrollments.`,
      'Delete Class',
      {
        confirmButtonText: 'Delete',
        cancelButtonText: 'Cancel',
        type: 'warning',
        confirmButtonClass: 'el-button--danger'
      }
    )

    await axios.delete(`${config.baseUrl}/classes/${classItem.id}`, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem('token')}`
      }
    })

    ElMessage.success('Class deleted successfully')
    await fetchClasses()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('Failed to delete class:', error)
      ElMessage.error('Failed to delete class')
    }
  }
}

const enterClass = (classItem) => {
  // Navigate to class-specific management view
  router.push({
    name: 'teacher-class',
    params: { classId: classItem.id },
    query: { 
      className: classItem.name, 
      classCode: classItem.code,
      studentCount: classItem.studentCount || 0
    }
  })
}

onMounted(fetchClasses)
</script>

<style scoped>
.teacher-home {
  padding: 20px;
  max-width: 1600px;
  margin: 0 auto;
  margin-top: 100px;
}

.welcome-section {
  text-align: center;
  margin-bottom: 40px;
  padding: 30px;
  background: linear-gradient(135deg, #2196F3 0%, #1976D2 100%);
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
}

.header-tabs {
  display: flex;
  gap: 20px;
}

.tab {
  color: #333;
  font-size: 1.5rem;
  margin: 0;
  cursor: pointer;
  padding-bottom: 10px;
  border-bottom: 3px solid transparent;
  transition: all 0.3s ease;
}

.tab.active {
  color: #2196F3;
  border-bottom-color: #2196F3;
}

.create-class {
  display: flex;
  align-items: center;
  gap: 15px;
}

.create-btn {
  background: #2196F3;
  color: white;
  border: none;
  padding: 12px 20px;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 8px;
}

.create-btn:hover {
  background: #1976D2;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(33, 150, 243, 0.3);
}

.class-grid {
  min-height: 400px;
}

.loading {
  text-align: center;
  padding: 60px;
  font-size: 1.1rem;
  color: #666;
}

.empty-state {
  text-align: center;
  padding: 60px;
  color: #666;
}

.empty-icon {
  font-size: 4rem;
  margin-bottom: 20px;
  color: #ddd;
}

.empty-state p {
  margin: 10px 0;
  font-size: 1.1rem;
}

.empty-tip {
  color: #999;
  font-size: 0.9rem;
}

.class-cards {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 25px;
}

.class-card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  cursor: pointer;
  overflow: hidden;
  border: 1px solid #f0f0f0;
}

.class-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
  border-color: #2196F3;
}

.card-header {
  padding: 20px;
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.card-actions {
  display: flex;
  align-items: center;
  gap: 10px;
}

.delete-btn {
  background: #ff4757;
  color: white;
  border: none;
  border-radius: 6px;
  padding: 8px 10px;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  opacity: 0.8;
}

.delete-btn:hover {
  background: #ff3742;
  opacity: 1;
  transform: scale(1.05);
}

.class-info h3 {
  margin: 0 0 8px 0;
  color: #333;
  font-size: 1.3rem;
  font-weight: 600;
}

.class-code {
  color: #666;
  font-size: 0.9rem;
  margin: 0;
}

.class-icon {
  background: #2196F3;
  color: white;
  width: 45px;
  height: 45px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2rem;
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
  align-items: center;
  gap: 8px;
}

.label {
  font-weight: 600;
  color: #555;
  min-width: 80px;
}

.value {
  color: #333;
  flex: 1;
}

.card-footer {
  padding: 15px 20px;
  background: #f8f9fa;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.assignment-count {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #666;
  font-size: 0.9rem;
}

.enter-arrow {
  color: #2196F3;
  font-size: 1.2rem;
  transition: transform 0.3s ease;
}

.class-card:hover .enter-arrow {
  transform: translateX(5px);
}

/* Modal Styles */
.modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  padding: 30px;
  border-radius: 12px;
  width: 90%;
  max-width: 500px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
}

.modal-content h3 {
  margin: 0 0 20px 0;
  color: #333;
  font-size: 1.5rem;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: 600;
  color: #555;
}

.form-group input,
.form-group textarea {
  width: 100%;
  padding: 12px;
  border: 2px solid #e1e5e9;
  border-radius: 8px;
  font-size: 14px;
  transition: border-color 0.3s ease;
}

.form-group input:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #2196F3;
}

.modal-actions {
  display: flex;
  gap: 15px;
  justify-content: flex-end;
  margin-top: 30px;
}

.cancel-btn,
.submit-btn {
  padding: 12px 24px;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.cancel-btn {
  background: #f5f5f5;
  color: #666;
}

.cancel-btn:hover {
  background: #e0e0e0;
}

.submit-btn {
  background: #2196F3;
  color: white;
}

.submit-btn:hover {
  background: #1976D2;
}
</style> 