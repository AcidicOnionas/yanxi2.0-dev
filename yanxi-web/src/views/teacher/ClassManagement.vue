<template>
  <div class="class-management">
    <div class="header-actions">
      <h2></h2>
      <div class="action-buttons">
        <button class="add-btn" @click="showAddClassModal = true">
          <i class="fas fa-plus"></i> Add New Class
        </button>
        <button class="add-btn homework" @click="showAddHomeworkModal = true">
          <i class="fas fa-file-upload"></i> Add New Homework
        </button>
      </div>
    </div>

    <div class="class-list">
      <div v-if="loading" class="loading">Loading classes...</div>
      <div v-else-if="classes.length === 0" class="empty-state">
        No classes found. Create your first class!
      </div>
      <div v-else class="class-table">
        <div class="table-header">
          <div class="code">Class Code</div>
          <div class="name">Class Name</div>
          <div class="teacher">Teacher</div>
          <div class="students">Students</div>
          <!-- <div class="created">Created At</div> -->
          <div class="actions">Actions</div>
        </div>
        <div v-for="classItem in classes" :key="classItem.id" class="class-row">
          <div class="code">{{ classItem.code }}</div>
          <div class="name">{{ classItem.name }}</div>
          <div class="teacher">{{ classItem.teacherName }}</div>
          <div class="students">{{ classItem.studentCount }} Students</div>
          <!-- <div class="created">{{ classItem.createdAt }}</div> -->
          <div class="actions">
            <button class="action-btn students" @click="manageStudents(classItem)">
              <i class="fas fa-users"></i> Students
            </button>
            <button class="action-btn edit" @click="editClass(classItem)">
              <i class="fas fa-edit"></i> Edit
            </button>
            <button class="action-btn delete" @click="deleteClass(classItem.id)">
              <i class="fas fa-trash"></i> Delete
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Add/Edit Class Modal -->
    <div v-if="showAddClassModal" class="modal">
      <div class="modal-content">
        <h3>{{ editingClass ? 'Edit Class' : 'Add New Class' }}</h3>
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
            <button type="submit" class="submit-btn">
              {{ editingClass ? 'Save Changes' : 'Create Class' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Add Homework Modal -->
    <div v-if="showAddHomeworkModal" class="modal">
      <div class="modal-content">
        <h3>Add New Assignment</h3>
        <form @submit.prevent="handleHomeworkSubmit">
          <div class="form-group">
            <label>Select Class</label>
            <select v-model="homeworkForm.classId" required>
              <option value="">Select a class</option>
              <option v-for="classItem in classes" :key="classItem.id" :value="classItem.id">
                {{ classItem.name }}
              </option>
            </select>
          </div>
          <div class="form-group">
            <label>Assignment Title</label>
            <input 
              type="text" 
              v-model="homeworkForm.title" 
              required 
              placeholder="Enter assignment title"
            >
          </div>
          <div class="form-group">
            <label>Description</label>
            <textarea 
              v-model="homeworkForm.description" 
              placeholder="Enter assignment description"
              rows="3"
            ></textarea>
          </div>
          <div class="form-group">
            <label>Due Date</label>
            <input 
              type="datetime-local" 
              v-model="homeworkForm.dueDate" 
              required
              :min="new Date().toISOString().slice(0, 16)"
            >
          </div>
          <div class="form-group">
            <label>Upload File</label>
            <input 
              type="file" 
              @change="handleFileUpload" 
              required
              accept=".pdf,.doc,.docx,.txt"
            >
          </div>
          <div class="modal-actions">
            <button type="button" class="cancel-btn" @click="closeHomeworkModal">Cancel</button>
            <button type="submit" class="submit-btn" :disabled="uploading">
              {{ uploading ? 'Uploading...' : 'Upload Assignment' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Manage Students Modal -->
    <div v-if="showStudentsModal" class="modal">
      <div class="modal-content large">
        <div class="modal-header">
          <h3>Manage Students - {{ selectedClass?.name }}</h3>
          <button class="close-btn" @click="closeStudentsModal">×</button>
        </div>
        <div class="students-content">
          <div v-if="loadingStudents" class="loading">Loading students...</div>
          <div v-else-if="classStudents.length === 0" class="empty-state">
            <i class="fas fa-users empty-icon"></i>
            <p>No students in this class yet</p>
            <p class="empty-tip">Students can join using class code: <strong>{{ selectedClass?.code }}</strong></p>
          </div>
          <div v-else class="students-table">
            <table>
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Email</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="student in classStudents" :key="student.id">
                  <td>{{ student.realName }}</td>
                  <td>{{ student.email }}</td>
                  <td class="actions">
                    <button class="action-btn remove" @click="removeStudentFromClass(student)">
                      <i class="fas fa-user-minus"></i> Remove
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import 'element-plus/dist/index.css'
import config from '@/config'

const router = useRouter()
const classes = ref([])
const loading = ref(true)
const showAddClassModal = ref(false)
const showAddHomeworkModal = ref(false)
const showStudentsModal = ref(false)
const uploading = ref(false)
const editingClass = ref(null)
const selectedClass = ref(null)
const classStudents = ref([])
const loadingStudents = ref(false)

const classForm = ref({
  name: '',
  description: ''
})

const homeworkForm = ref({
  classId: '',
  title: '',
  description: '',
  dueDate: '',
  file: null
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
    console.error('Error fetching classes:', error)
  } finally {
    loading.value = false
  }
}

const handleSubmit = async () => {
  try {
    if (editingClass.value) {
      await axios.put(`${config.baseUrl}/classes/${editingClass.value.id}`, classForm.value, {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('token')}`
        }
      })
    } else {
      await axios.post(`${config.baseUrl}/classes/`, classForm.value, {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('token')}`
        }
      })
    }
    await fetchClasses()
    closeModal()
  } catch (error) {
    console.error('Error saving class:', error)
  }
}

const editClass = (classItem) => {
  editingClass.value = classItem
  classForm.value = { ...classItem }
  showAddClassModal.value = true
}

const deleteClass = async (classId) => {
  if (!confirm('Are you sure you want to delete this class?')) return
  
  try {
    await axios.delete(`${config.baseUrl}/classes/${classId}`, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem('token')}`
      }
    })
    await fetchClasses()
  } catch (error) {
    console.error('Error deleting class:', error)
  }
}

const closeModal = () => {
  showAddClassModal.value = false
  editingClass.value = null
  classForm.value = {
    name: '',
    description: ''
  }
}

const manageStudents = async (classItem) => {
  selectedClass.value = classItem
  showStudentsModal.value = true
  await fetchClassStudents(classItem.id)
}

const fetchClassStudents = async (classId) => {
  try {
    loadingStudents.value = true
    const response = await axios.get(`${config.baseUrl}/classes/teacher/students`, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem('token')}`
      },
      params: { classId }
    })
    classStudents.value = response.data
  } catch (error) {
    console.error('Error fetching class students:', error)
    ElMessage.error('Failed to load students')
  } finally {
    loadingStudents.value = false
  }
}

const removeStudentFromClass = async (student) => {
  try {
    await ElMessageBox.confirm(
      `Are you sure you want to remove ${student.realName} from ${selectedClass.value.name}?`,
      'Remove Student',
      {
        confirmButtonText: 'Remove',
        cancelButtonText: 'Cancel',
        type: 'warning',
        confirmButtonClass: 'el-button--danger'
      }
    )

          await axios.delete(`${config.baseUrl}/classes/${selectedClass.value.id}/students/${student.id}`, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem('token')}`
      }
    })
    
    ElMessage.success(`${student.realName} has been removed from ${selectedClass.value.name}`)
    await fetchClassStudents(selectedClass.value.id) // Refresh student list
    await fetchClasses() // Refresh class list to update student count
  } catch (error) {
    if (error === 'cancel') {
      return
    }
    console.error('Error removing student from class:', error)
    ElMessage.error('Failed to remove student from class. Please try again.')
  }
}

const closeStudentsModal = () => {
  showStudentsModal.value = false
  selectedClass.value = null
  classStudents.value = []
}

const handleFileUpload = (event) => {
  homeworkForm.value.file = event.target.files[0]
}

const handleHomeworkSubmit = async () => {
  try {
    uploading.value = true
    const formData = new FormData()
    formData.append('classId', homeworkForm.value.classId)
    formData.append('title', homeworkForm.value.title)
    formData.append('description', homeworkForm.value.description)
    
    // Format due date for backend (ISO_LOCAL_DATE_TIME format)
    const dueDateFormatted = homeworkForm.value.dueDate + ':00' // Add seconds
    formData.append('dueDate', dueDateFormatted)
    formData.append('file', homeworkForm.value.file)

          await axios.post(`${config.baseUrl}/assignments`, formData, {
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('token')}`,
        'Content-Type': 'multipart/form-data'
      }
    })

    closeHomeworkModal()
    alert('Assignment added successfully!')
  } catch (error) {
    console.error('Error uploading assignment:', error)
    alert('Failed to upload assignment. Please try again.')
  } finally {
    uploading.value = false
  }
}

const closeHomeworkModal = () => {
  showAddHomeworkModal.value = false
  homeworkForm.value = {
    classId: '',
    title: '',
    description: '',
    dueDate: '',
    file: null
  }
}

onMounted(fetchClasses)
</script>

<style scoped>
.class-management {
  padding: 20px;
}

.header-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}

.action-buttons {
  display: flex;
  gap: 10px;
}

.add-btn {
  padding: 10px 20px;
  background: #4CAF50;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: bold;
  transition: background 0.3s;
}

.add-btn:hover {
  background: #388E3C;
}

.add-btn.homework {
  background: #2196F3;
}

.add-btn.homework:hover {
  background: #1976D2;
}

.class-table {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.table-header {
  display: grid;
  grid-template-columns: 120px 2fr 1fr 1fr 1fr 1fr;
  padding: 16px;
  background: #f8f9fa;
  font-weight: bold;
  color: #2c3e50;
  border-bottom: 2px solid #eee;
}

.class-row {
  display: grid;
  grid-template-columns: 120px 2fr 1fr 1fr 1fr 1fr;
  padding: 16px;
  align-items: center;
  border-bottom: 1px solid #eee;
  transition: background-color 0.2s;
}

.class-row:hover {
  background-color: #f8f9fa;
}

.class-row .code {
  font-family: monospace;
  background-color: #f5f5f5;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 0.9em;
}

.class-row .name {
  font-weight: 500;
  color: #2c3e50;
}

.class-row .teacher {
  color: #666;
}

.class-row .students {
  color: #666;
}

.class-row .created {
  color: #666;
  font-size: 0.9em;
}

.class-row .actions {
  display: flex;
  gap: 8px;
  justify-content: flex-end;
}

.action-btn {
  padding: 6px 12px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 0.9em;
  transition: all 0.2s;
}

.action-btn.students {
  background: #E8F5E9;
  color: #388E3C;
}

.action-btn.students:hover {
  background: #C8E6C9;
}

.action-btn.edit {
  background: #E3F2FD;
  color: #1976D2;
}

.action-btn.edit:hover {
  background: #BBDEFB;
}

.action-btn.delete {
  background: #FFEBEE;
  color: #D32F2F;
}

.action-btn.delete:hover {
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
  z-index: 1000;
}

.modal-content {
  background: white;
  padding: 30px;
  border-radius: 12px;
  width: 100%;
  max-width: 500px;
  max-height: 90vh;
  overflow-y: auto;
  position: relative;
  z-index: 1001;
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

.form-group input,
.form-group textarea {
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

select {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 1rem;
  background-color: white;
}

input[type="file"] {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 1rem;
  background-color: white;
}

/* Students Modal Styles */
.modal-content.large {
  max-width: 800px;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 1px solid #eee;
}

.modal-header h3 {
  margin: 0;
  color: #2c3e50;
}

.close-btn {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: #666;
  padding: 0;
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  transition: background-color 0.2s;
}

.close-btn:hover {
  background-color: #f5f5f5;
}

.students-content {
  min-height: 300px;
}

.students-table {
  background: white;
  border-radius: 8px;
  border: 1px solid #eee;
  overflow: hidden;
}

.students-table table {
  width: 100%;
  border-collapse: collapse;
}

.students-table th,
.students-table td {
  padding: 12px 15px;
  text-align: left;
  border-bottom: 1px solid #eee;
}

.students-table th {
  background-color: #f8f9fa;
  font-weight: 600;
  color: #2c3e50;
}

.students-table tr:hover {
  background-color: #f8f9fa;
}

.students-table .actions {
  text-align: right;
}

.action-btn.remove {
  background: #FFEBEE;
  color: #D32F2F;
  font-size: 0.85rem;
  padding: 5px 10px;
}

.action-btn.remove:hover {
  background: #FFCDD2;
}

.empty-state {
  text-align: center;
  padding: 40px;
  color: #666;
}

.empty-icon {
  font-size: 48px;
  color: #ddd;
  margin-bottom: 15px;
}

.empty-tip {
  margin-top: 10px;
  font-size: 0.9rem;
  color: #999;
}

.empty-tip strong {
  color: #4CAF50;
  font-family: monospace;
  background: #f5f5f5;
  padding: 2px 6px;
  border-radius: 3px;
}
</style> 