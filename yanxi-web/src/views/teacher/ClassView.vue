<template>
  <div class="teacher-class-view">
    <div class="class-header">
      <button class="back-button" @click="goBack">
        <i class="fas fa-arrow-left"></i>
        <span>Back to Classes</span>
      </button>
      <div class="class-info">
        <h1>{{ className }}</h1>
        <p class="class-details">
          <span>Code: {{ classCode }}</span>
          <span class="divider">•</span>
          <span>{{ studentCount }} students enrolled</span>
        </p>
      </div>
      <div class="header-spacer"></div>
    </div>

    <div class="tabs-section">
      <div class="tab-buttons">
        <button 
          class="tab-btn" 
          :class="{ active: activeTab === 'assignments' }"
          @click="activeTab = 'assignments'"
        >
          <i class="fas fa-file-alt"></i> Assignments
        </button>
        <button 
          class="tab-btn" 
          :class="{ active: activeTab === 'students' }"
          @click="activeTab = 'students'"
        >
          <i class="fas fa-users"></i> Students
        </button>
      </div>
    </div>

    <!-- Assignments Tab -->
    <div v-if="activeTab === 'assignments'" class="assignments-section">
      <div class="section-header">
        <h2>Class Assignments</h2>
        <button class="add-btn" @click="showAddAssignmentModal = true">
          <i class="fas fa-plus"></i> Add Assignment
        </button>
      </div>

      <div class="assignment-list">
        <div v-if="loadingAssignments" class="loading">Loading assignments...</div>
        <div v-else-if="assignments.length === 0" class="empty-state">
          <i class="fas fa-file-alt empty-icon"></i>
          <p>No assignments created yet</p>
          <p class="empty-tip">Create your first assignment for this class</p>
        </div>
        <div v-else class="assignment-table">
          <table>
            <thead>
              <tr>
                <th class="col-title">Assignment Title</th>
                <th class="col-description">Description</th>
                <th class="col-date">Created</th>
                <th class="col-date">Due Date</th>
                <th class="col-submissions">Submissions</th>
                <th class="col-actions">Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="assignment in assignments" :key="assignment.id">
                <td class="col-title">{{ assignment.title }}</td>
                <td class="col-description">{{ assignment.description }}</td>
                <td class="col-date">{{ formatDate(assignment.createdAt) }}</td>
                <td class="col-date">
                  <span v-if="assignment.dueDate" :class="getDueDateClass(assignment.dueDate)">
                    {{ formatDate(assignment.dueDate) }}
                  </span>
                  <span v-else class="no-due-date">No due date</span>
                </td>
                <td class="col-submissions">
                  <span class="submission-count">
                    {{ assignment.submissionCount || 0 }} / {{ studentCount }}
                  </span>
                </td>
                <td class="col-actions">
                  <div class="actions-container">
                    <button class="action-btn view" @click="viewSubmissions(assignment)">
                      <i class="fas fa-eye"></i> View Submissions
                    </button>
                    <button class="action-btn edit" @click="editAssignment(assignment)">
                      <i class="fas fa-edit"></i> Edit
                    </button>
                    <button class="action-btn delete" @click="deleteAssignment(assignment.id)">
                      <i class="fas fa-trash"></i> Delete
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Students Tab -->
    <div v-if="activeTab === 'students'" class="students-section">
      <div class="section-header">
        <h2>Class Students</h2>
        <div class="class-code-display">
          <span>Students can join with code: <strong>{{ classCode }}</strong></span>
        </div>
      </div>

      <div class="students-list">
        <div v-if="loadingStudents" class="loading">Loading students...</div>
        <div v-else-if="students.length === 0" class="empty-state">
          <i class="fas fa-users empty-icon"></i>
          <p>No students enrolled yet</p>
          <p class="empty-tip">Share the class code <strong>{{ classCode }}</strong> for students to join</p>
        </div>
        <div v-else class="students-table">
          <table>
            <thead>
              <tr>
                <th class="col-name">Student Name</th>
                <th class="col-email">Email</th>
                <th class="col-joined">Joined Date</th>
                <th class="col-assignments">Assignments Submitted</th>
                <th class="col-actions">Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="student in students" :key="student.id">
                <td class="col-name">{{ student.realName }}</td>
                <td class="col-email">{{ student.email }}</td>
                <td class="col-joined">{{ formatDate(student.joinedAt) }}</td>
                <td class="col-assignments">
                  <span class="assignment-count">
                    {{ student.submittedAssignments || 0 }} / {{ assignments.length }}
                  </span>
                </td>
                <td class="col-actions">
                  <button class="action-btn remove" @click="removeStudent(student)">
                    <i class="fas fa-user-minus"></i> Remove
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Add Assignment Modal -->
    <div v-if="showAddAssignmentModal" class="modal">
      <div class="modal-content">
        <h3>{{ editingAssignment ? 'Edit Assignment' : 'Add New Assignment' }}</h3>
        <form @submit.prevent="handleAssignmentSubmit">
          <div class="form-group">
            <label>Assignment Title</label>
            <input 
              type="text" 
              v-model="assignmentForm.title" 
              required 
              placeholder="Enter assignment title"
            >
          </div>
          <div class="form-group">
            <label>Description</label>
            <textarea 
              v-model="assignmentForm.description" 
              placeholder="Enter assignment description"
              rows="3"
            ></textarea>
          </div>
          <div class="form-group">
            <label>Due Date</label>
            <input 
              type="datetime-local" 
              v-model="assignmentForm.dueDate" 
              :min="new Date().toISOString().slice(0, 16)"
            >
          </div>
          <div class="form-group" v-if="!editingAssignment">
            <label>Upload Assignment File</label>
            <input 
              type="file" 
              @change="handleFileUpload" 
              accept=".pdf,.doc,.docx,.txt"
            >
          </div>
          <div class="modal-actions">
            <button type="button" class="cancel-btn" @click="closeAssignmentModal">Cancel</button>
            <button type="submit" class="submit-btn" :disabled="uploading">
              {{ uploading ? 'Uploading...' : (editingAssignment ? 'Save Changes' : 'Create Assignment') }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useRouter, useRoute } from 'vue-router'
import axios from 'axios'
import config from '@/config'
import 'element-plus/dist/index.css'

const router = useRouter()
const route = useRoute()

// Get class info from route params/query
const classId = ref(route.params.classId)
const className = ref(route.query.className || 'Class')
const classCode = ref(route.query.classCode || '')
const studentCount = ref(parseInt(route.query.studentCount) || 0)

const activeTab = ref('assignments')
const loadingAssignments = ref(false)
const loadingStudents = ref(false)
const assignments = ref([])
const students = ref([])
const showAddAssignmentModal = ref(false)
const editingAssignment = ref(null)
const uploading = ref(false)

const assignmentForm = ref({
  title: '',
  description: '',
  dueDate: '',
  file: null
})

const fetchAssignments = async () => {
  try {
    loadingAssignments.value = true
    // Use the general assignments endpoint with classId parameter for better caching
    const response = await axios.get(`${config.baseUrl}/assignments`, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem('token')}`
      },
      params: {
        classId: classId.value,
        _t: Date.now() // Cache-busting parameter
      }
    })
    // Filter assignments for this specific class (double-check on frontend)
    assignments.value = response.data.filter(assignment => 
      assignment.classId === parseInt(classId.value)
    )
  } catch (error) {
    console.error('Failed to fetch assignments:', error)
    // Set empty array if API fails
    assignments.value = []
  } finally {
    loadingAssignments.value = false
  }
}

const fetchStudents = async () => {
  try {
    loadingStudents.value = true
    const response = await axios.get(`${config.baseUrl}/classes/teacher/students`, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem('token')}`
      },
      params: { classId: classId.value }
    })
    students.value = response.data
    studentCount.value = response.data.length
  } catch (error) {
    console.error('Failed to fetch students:', error)
    // Set empty array if API fails
    students.value = []
  } finally {
    loadingStudents.value = false
  }
}

const handleAssignmentSubmit = async () => {
  try {
    uploading.value = true
    
    if (editingAssignment.value) {
      // Update existing assignment
      await axios.put(`${config.baseUrl}/assignments/${editingAssignment.value.id}`, {
        title: assignmentForm.value.title,
        description: assignmentForm.value.description,
        dueDate: assignmentForm.value.dueDate
      }, {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('token')}`
        }
      })
      ElMessage.success('Assignment updated successfully')
    } else {
      // Create new assignment
      const formData = new FormData()
      formData.append('title', assignmentForm.value.title)
      formData.append('description', assignmentForm.value.description)
      formData.append('classId', classId.value)
      formData.append('dueDate', assignmentForm.value.dueDate)
      if (assignmentForm.value.file) {
        formData.append('file', assignmentForm.value.file)
      }

      await axios.post(`${config.baseUrl}/assignments`, formData, {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('token')}`,
          'Content-Type': 'multipart/form-data'
        }
      })
      ElMessage.success('Assignment created successfully')
    }
    
    closeAssignmentModal()
    await fetchAssignments()
  } catch (error) {
    console.error('Failed to save assignment:', error)
    ElMessage.error('Failed to save assignment')
  } finally {
    uploading.value = false
  }
}

const handleFileUpload = (event) => {
  assignmentForm.value.file = event.target.files[0]
}

const closeAssignmentModal = () => {
  showAddAssignmentModal.value = false
  editingAssignment.value = null
  assignmentForm.value = {
    title: '',
    description: '',
    dueDate: '',
    file: null
  }
}

const editAssignment = (assignment) => {
  editingAssignment.value = assignment
  assignmentForm.value = {
    title: assignment.title,
    description: assignment.description,
    dueDate: assignment.dueDate ? new Date(assignment.dueDate).toISOString().slice(0, 16) : '',
    file: null
  }
  showAddAssignmentModal.value = true
}

const deleteAssignment = async (assignmentId) => {
  try {
    await ElMessageBox.confirm('Are you sure you want to delete this assignment?', 'Confirm Delete', {
      type: 'warning'
    })
    
    // Optimistically remove from UI first
    const originalAssignments = [...assignments.value]
    assignments.value = assignments.value.filter(assignment => assignment.id !== assignmentId)
    
    try {
      await axios.delete(`${config.baseUrl}/assignments/${assignmentId}`, {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('token')}`
        }
      })
      
      ElMessage.success('Assignment deleted successfully')
      // Refresh from server to ensure consistency
      await fetchAssignments()
    } catch (deleteError) {
      // Revert the optimistic update if deletion failed
      assignments.value = originalAssignments
      console.error('Failed to delete assignment:', deleteError)
      ElMessage.error('Failed to delete assignment')
    }
  } catch (error) {
    if (error.action !== 'cancel') {
      console.error('Failed to delete assignment:', error)
    }
  }
}

const removeStudent = async (student) => {
  try {
    await ElMessageBox.confirm(`Are you sure you want to remove ${student.realName} from this class?`, 'Confirm Remove', {
      type: 'warning'
    })
    
    await axios.delete(`${config.baseUrl}/classes/${classId.value}/students/${student.id}`, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem('token')}`
      }
    })
    
    ElMessage.success('Student removed successfully')
    await fetchStudents()
  } catch (error) {
    if (error.action !== 'cancel') {
      console.error('Failed to remove student:', error)
      ElMessage.error('Failed to remove student')
    }
  }
}

const viewSubmissions = (assignment) => {
  // Navigate to submissions view (could be implemented later)
  ElMessage.info('Submissions view will be implemented soon')
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  return new Date(dateString).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const getDueDateClass = (dueDate) => {
  if (!dueDate) return ''
  const now = new Date()
  const due = new Date(dueDate)
  const diffDays = (due - now) / (1000 * 60 * 60 * 24)
  
  if (diffDays < 0) return 'overdue'
  if (diffDays < 1) return 'due-soon'
  return 'due-normal'
}

const goBack = () => {
  router.push('/teacher')
}

onMounted(() => {
  console.log('ClassView mounted with classId:', classId.value)
  fetchAssignments()
  fetchStudents()
})
</script>

<style scoped>
.teacher-class-view {
  padding: 20px;
  max-width: 1600px;
  margin: 0 auto;
  margin-top: 100px;
}

.class-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 30px;
  padding: 20px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.back-button {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #2196F3;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s ease;
  background: none;
  border: 2px solid #2196F3;
  border-radius: 8px;
  padding: 10px 16px;
  font-size: 14px;
}

.back-button:hover {
  background: #2196F3;
  color: white;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(33, 150, 243, 0.3);
}

.class-info {
  text-align: center;
  flex: 1;
}

.header-spacer {
  width: 140px; /* Same width as back button to center the content */
}

.class-info h1 {
  margin: 0 0 8px 0;
  color: #333;
  font-size: 1.8rem;
}

.class-details {
  color: #666;
  margin: 0;
}

.divider {
  margin: 0 10px;
}

.tabs-section {
  margin-bottom: 30px;
}

.tab-buttons {
  display: flex;
  gap: 10px;
  border-bottom: 2px solid #e5e7eb;
  padding-bottom: 10px;
}

.tab-btn {
  padding: 12px 24px;
  border: none;
  background: none;
  font-size: 16px;
  font-weight: 600;
  color: #6b7280;
  cursor: pointer;
  transition: all 0.3s ease;
  border-radius: 8px 8px 0 0;
  display: flex;
  align-items: center;
  gap: 8px;
}

.tab-btn:hover {
  color: #2196F3;
  background: #f3f4f6;
}

.tab-btn.active {
  color: #2196F3;
  border-bottom: 3px solid #2196F3;
  background: #f3f4f6;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
}

.section-header h2 {
  color: #333;
  margin: 0;
}

.add-btn {
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

.add-btn:hover {
  background: #1976D2;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(33, 150, 243, 0.3);
}

.class-code-display {
  background: #f8f9fa;
  padding: 12px 16px;
  border-radius: 8px;
  color: #555;
  border: 1px solid #e9ecef;
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

.assignment-table,
.students-table {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.assignment-table table,
.students-table table {
  width: 100%;
  border-collapse: collapse;
}

.assignment-table th,
.students-table th,
.assignment-table td,
.students-table td {
  padding: 16px;
  text-align: left;
  border-bottom: 1px solid #f0f0f0;
}

.assignment-table th,
.students-table th {
  background: #f8f9fa;
  font-weight: 600;
  color: #555;
}

.col-title { width: 20%; }
.col-description { width: 25%; }
.col-date { width: 15%; }
.col-submissions { width: 12%; }
.col-actions { width: 20%; }
.col-name { width: 20%; }
.col-email { width: 25%; }
.col-joined { width: 15%; }
.col-assignments { width: 15%; }

.actions-container {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.action-btn {
  padding: 6px 12px;
  border: none;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 4px;
}

.action-btn.view {
  background: #e3f2fd;
  color: #1976d2;
}

.action-btn.edit {
  background: #fff3e0;
  color: #f57c00;
}

.action-btn.delete,
.action-btn.remove {
  background: #ffebee;
  color: #d32f2f;
}

.action-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
}

.submission-count,
.assignment-count {
  background: #e8f5e8;
  color: #2e7d32;
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 600;
}

.due-normal { color: #333; }
.due-soon { color: #ff9800; font-weight: 600; }
.overdue { color: #f44336; font-weight: 600; }
.no-due-date { color: #999; font-style: italic; }

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
  max-width: 600px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
  max-height: 90vh;
  overflow-y: auto;
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

.submit-btn:disabled {
  background: #ccc;
  cursor: not-allowed;
}
</style> 