<template>
  <div class="student-management">
    <div class="header-actions">
      <div class="header-info">
        <h2>Student Management</h2>
        <p v-if="selectedClass" class="help-text">
          <i class="fas fa-info-circle"></i>
          Select a specific class to remove students from that class
        </p>
      </div>
      <div class="filters">
        <select v-model="selectedClass" @change="handleClassChange" class="class-select">
          <option value="">All Classes</option>
          <option v-for="classItem in classes" :key="classItem.id" :value="classItem.id">
            {{ classItem.name }}
          </option>
        </select>
        <div class="search-box">
          <input 
            type="text" 
            v-model="searchQuery" 
            placeholder="Search by email..."
            @input="handleSearch"
          />
        </div>
      </div>
    </div>

    <div class="student-list">
      <div v-if="loading" class="loading">Loading students...</div>
      <div v-else-if="filteredStudents.length === 0" class="empty-state">
        No students found.
      </div>
      <div v-else class="student-table">
        <table>
          <thead>
            <tr>
              <th>Name</th>
              <th>Email</th>
              <th>Phone</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="student in filteredStudents" :key="student.id">
              <td>{{ student.realName }}</td>
              <td>{{ student.email }}</td>
              <td>{{ student.phone }}</td>
              <td class="actions">
                <button class="action-btn view" @click="viewStudentDetails(student)">
                  <i class="fas fa-eye"></i> View
                </button>
                <button class="action-btn edit" @click="editStudent(student)">
                  <i class="fas fa-edit"></i> Edit
                </button>
                <button 
                  v-if="selectedClass" 
                  class="action-btn remove" 
                  @click="removeStudentFromClass(student)"
                >
                  <i class="fas fa-user-minus"></i> Remove
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Student Details Modal -->
    <div v-if="showDetailsModal" class="modal">
      <div class="modal-content">
        <div class="modal-header">
          <h3>Student Details</h3>
          <button class="close-btn" @click="closeDetailsModal">×</button>
        </div>
        <div v-if="selectedStudent" class="student-details">
          <div class="detail-group">
            <label>Name</label>
            <p>{{ selectedStudent.realName }}</p>
          </div>
          <div class="detail-group">
            <label>Email</label>
            <p>{{ selectedStudent.email }}</p>
          </div>
          <div class="detail-group">
            <label>Classes</label>
            <div class="class-list">
              <div v-for="classItem in selectedStudent.classes" :key="classItem.id" class="class-item">
                {{ classItem.name }}
              </div>
            </div>
          </div>
          <div class="detail-group">
            <label>Courses</label>
            <div class="course-list">
              <div v-for="course in selectedStudent.courses" :key="course.id" class="course-item">
                {{ course.name }}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Edit Student Modal -->
    <div v-if="showEditModal" class="modal">
      <div class="modal-content">
        <h3>Edit Student</h3>
        <form @submit.prevent="handleSubmit">
          <div class="form-group">
            <label>Name</label>
            <input 
              type="text" 
              v-model="editForm.realName" 
              required 
              placeholder="Enter student name"
            >
          </div>
          <div class="form-group">
            <label>Email</label>
            <input 
              type="email" 
              v-model="editForm.email" 
              required 
              placeholder="Enter student email"
            >
          </div>
          <div class="modal-actions">
            <button type="button" class="cancel-btn" @click="closeEditModal">Cancel</button>
            <button type="submit" class="submit-btn">Save Changes</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import config from '@/config'
import { useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import 'element-plus/dist/index.css'

const route = useRoute()
const students = ref([])
const classes = ref([])
const loading = ref(true)
const searchQuery = ref('')
const selectedClass = ref('')
const showDetailsModal = ref(false)
const showEditModal = ref(false)
const selectedStudent = ref(null)

const editForm = ref({
  realName: '',
  email: ''
})

const filteredStudents = computed(() => {
  if (!searchQuery.value) return students.value
  const query = searchQuery.value.toLowerCase()
  return students.value.filter(student => 
    student.realName.toLowerCase().includes(query) || 
    student.email.toLowerCase().includes(query)
  )
})

const fetchClasses = async () => {
  try {
    const response = await axios.get(`${config.baseUrl}/classes/teacher`, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem('token')}`
      }
    })
    classes.value = response.data
  } catch (error) {
    console.error('Error fetching classes:', error)
  }
}

const fetchStudents = async () => {
  try {
    loading.value = true
    const params = {}
    if (searchQuery.value) {
      params.email = searchQuery.value
    }
    if (selectedClass.value) {
      params.classId = selectedClass.value
    }
    
    const response = await axios.get(`${config.baseUrl}/classes/teacher/students`, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem('token')}`
      },
      params
    })
    students.value = response.data
  } catch (error) {
    console.error('Error fetching students:', error)
  } finally {
    loading.value = false
  }
}

const viewStudentDetails = async (student) => {
  try {
    const response = await axios.get(`${config.baseUrl}/students/${student.id}`, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem('token')}`
      }
    })
    selectedStudent.value = response.data
    showDetailsModal.value = true
  } catch (error) {
    console.error('Error fetching student details:', error)
  }
}

const editStudent = (student) => {
  editForm.value = { ...student }
  showEditModal.value = true
}

const handleSubmit = async () => {
  try {
    await axios.put(`${config.baseUrl}/students/${editForm.value.id}`, editForm.value, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem('token')}`
      }
    })
    await fetchStudents()
    closeEditModal()
  } catch (error) {
    console.error('Error updating student:', error)
  }
}

const handleSearch = () => {
  // 实时搜索，不需要额外处理
}

const handleClassChange = () => {
  fetchStudents()
}

const removeStudentFromClass = async (student) => {
  if (!selectedClass.value) {
    ElMessage.warning('Please select a class first')
    return
  }

  const className = classes.value.find(c => c.id === parseInt(selectedClass.value))?.name || 'this class'
  
  try {
    await ElMessageBox.confirm(
      `Are you sure you want to remove ${student.realName} from ${className}?`,
      'Remove Student',
      {
        confirmButtonText: 'Remove',
        cancelButtonText: 'Cancel',
        type: 'warning',
        confirmButtonClass: 'el-button--danger'
      }
    )

    await axios.delete(`${config.baseUrl}/classes/${selectedClass.value}/students/${student.id}`, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem('token')}`
      }
    })
    
    ElMessage.success(`${student.realName} has been removed from ${className}`)
    await fetchStudents() // Refresh the student list
  } catch (error) {
    if (error === 'cancel') {
      // User cancelled the operation
      return
    }
    console.error('Error removing student from class:', error)
    ElMessage.error('Failed to remove student from class. Please try again.')
  }
}

const closeDetailsModal = () => {
  showDetailsModal.value = false
  selectedStudent.value = null
}

const closeEditModal = () => {
  showEditModal.value = false
  editForm.value = {
    realName: '',
    email: ''
  }
}

onMounted(() => {
  // 如果URL中有classId参数，则自动选择该班级
  if (route.query.classId) {
    selectedClass.value = route.query.classId
  }
  fetchClasses()
  fetchStudents()
})
</script>

<style scoped>
.student-management {
  padding: 20px;
}

.header-actions {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 30px;
}

.header-info h2 {
  margin: 0 0 5px 0;
  color: #2c3e50;
}

.help-text {
  margin: 0;
  color: #666;
  font-size: 0.9rem;
  display: flex;
  align-items: center;
  gap: 5px;
}

.help-text i {
  color: #4CAF50;
}

.filters {
  display: flex;
  gap: 15px;
  align-items: center;
}

.class-select {
  padding: 10px 15px;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 1rem;
  min-width: 200px;
  background-color: white;
}

.search-box input {
  padding: 10px 15px;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 1rem;
  width: 300px;
}

.student-table {
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

table {
  width: 100%;
  border-collapse: collapse;
}

th, td {
  padding: 15px;
  text-align: left;
  border-bottom: 1px solid #eee;
}

th {
  background-color: #f8f9fa;
  font-weight: 600;
  color: #2c3e50;
}

tr:hover {
  background-color: #f8f9fa;
}

.actions {
  display: flex;
  gap: 10px;
}

.action-btn {
  padding: 6px 12px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 0.9rem;
  transition: all 0.3s;
}

.action-btn.view {
  background: #E3F2FD;
  color: #1976D2;
}

.action-btn.view:hover {
  background: #BBDEFB;
}

.action-btn.edit {
  background: #E8F5E9;
  color: #388E3C;
}

.action-btn.edit:hover {
  background: #C8E6C9;
}

.action-btn.remove {
  background: #FFEBEE;
  color: #D32F2F;
}

.action-btn.remove:hover {
  background: #FFCDD2;
}

.modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-content {
  background: white;
  padding: 30px;
  border-radius: 12px;
  width: 100%;
  max-width: 600px;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.close-btn {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: #666;
}

.student-details {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.detail-group {
  margin-bottom: 15px;
}

.detail-group label {
  display: block;
  font-weight: bold;
  color: #2c3e50;
  margin-bottom: 5px;
}

.detail-group p {
  margin: 0;
  color: #666;
}

.class-list,
.course-list {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.class-item,
.course-item {
  background: #f3f4f6;
  padding: 5px 10px;
  border-radius: 4px;
  font-size: 0.9rem;
  color: #4b5563;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: bold;
  color: #2c3e50;
}

.form-group input {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 1rem;
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 20px;
}

.cancel-btn,
.submit-btn {
  padding: 10px 20px;
  border-radius: 6px;
  cursor: pointer;
  font-weight: bold;
}

.cancel-btn {
  background: #f3f4f6;
  border: 1px solid #ddd;
  color: #666;
}

.submit-btn {
  background: #4CAF50;
  border: none;
  color: white;
}

.loading,
.empty-state {
  text-align: center;
  padding: 40px;
  color: #666;
}
</style> 