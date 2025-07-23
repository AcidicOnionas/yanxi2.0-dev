<template>
  <div class="class-assignments">
    <div class="class-header">
      <div class="back-button" @click="goBack">
        <i class="fas fa-arrow-left"></i>
        <span>返回班级</span>
      </div>
      <div class="class-info">
        <h1>{{ className }}</h1>
        <p class="teacher-info">教师: {{ teacherName }}</p>
      </div>
    </div>

    <div class="assignments-section">
      <div class="section-header">
        <h2>作业列表</h2>
        <div class="filters">
          <el-select v-model="filterSubmitted" placeholder="筛选提交状态" @change="fetchAssignments" style="width: 180px;">
            <el-option label="全部" :value="null" />
            <el-option label="已提交" :value="true" />
            <el-option label="未提交" :value="false" />
          </el-select>
        </div>
      </div>

      <div class="assignment-list">
        <div v-if="loading" class="loading">加载作业中...</div>
        <div v-else-if="assignmentList.length === 0" class="empty-state">
          <i class="fas fa-book empty-icon"></i>
          <p>暂无作业数据</p>
        </div>
        <div v-else class="assignment-table">
          <table>
            <thead>
              <tr>
                <th class="col-title">作业标题</th>
                <th class="col-description">作业描述</th>
                <th class="col-date">发布日期</th>
                <th class="col-date">截止日期</th>
                <th class="col-status">提交状态</th>
                <th class="col-actions">操作</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="assignment in assignmentList" :key="assignment.id">
                <td class="col-title">{{ assignment.title }}</td>
                <td class="col-description">{{ assignment.description }}</td>
                <td class="col-date">{{ formatDate(assignment.createdAt) }}</td>
                <td class="col-date">
                  <span v-if="assignment.dueDate" :class="getDueDateClass(assignment.dueDate)">
                    {{ formatDate(assignment.dueDate) }}
                  </span>
                  <span v-else class="no-due-date">无截止日期</span>
                </td>
                <td class="col-status">
                  <el-tag v-if="assignment.submitted" type="success">
                    已提交
                  </el-tag>
                  <el-tag v-else-if="isOverdue(assignment.dueDate)" type="danger">
                    已过期
                  </el-tag>
                  <el-tag v-else type="warning">
                    未提交
                  </el-tag>
                </td>
                <td class="col-actions">
                  <div class="actions-container">
                    <button class="action-btn download" @click="downloadAssignment(assignment)">
                      <i class="fas fa-download"></i> 下载作业
                    </button>
                    <button 
                      v-if="!assignment.submitted && !isOverdue(assignment.dueDate)" 
                      class="action-btn submit" 
                      @click="openUploadModal(assignment)"
                    >
                      <i class="fas fa-upload"></i> 提交作业
                    </button>
                    <button 
                      v-if="!assignment.submitted && isOverdue(assignment.dueDate)" 
                      class="action-btn disabled" 
                      disabled
                      title="作业已过期，无法提交"
                    >
                      <i class="fas fa-upload"></i> 已过期
                    </button>
                    <div v-if="assignment.submitted" class="submitted-actions">
                      <button 
                        class="action-btn view" 
                        @click="handleViewSubmission(assignment)"
                      >
                        <i class="fas fa-eye"></i> 查看提交
                      </button>
                      <button 
                        v-if="!isOverdue(assignment.dueDate)"
                        class="action-btn update" 
                        @click="openUpdateModal(assignment)"
                      >
                        <i class="fas fa-edit"></i> 更新提交
                      </button>
                      <button 
                        v-if="isOverdue(assignment.dueDate)"
                        class="action-btn disabled" 
                        disabled
                        title="作业已过期，无法更新"
                      >
                        <i class="fas fa-edit"></i> 已过期
                      </button>
                      <button 
                        class="action-btn unsubmit" 
                        @click="handleUnsubmit(assignment)"
                      >
                        <i class="fas fa-times"></i> 取消提交
                      </button>
                    </div>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- 作业上传弹窗 -->
    <el-dialog v-model="showUploadModal" title="提交作业" width="400px">
      <input type="file" @change="handleFileChange" />
      <template #footer>
        <el-button @click="showUploadModal = false">取消</el-button>
        <el-button type="primary" :loading="uploading" @click="submitAssignment">提交</el-button>
      </template>
    </el-dialog>

    <!-- 作业更新弹窗 -->
    <el-dialog v-model="showUpdateModal" title="更新作业提交" width="400px">
      <div class="update-modal-content">
        <p>选择新的作业文件来替换之前的提交：</p>
        <input type="file" @change="handleUpdateFileChange" />
      </div>
      <template #footer>
        <el-button @click="showUpdateModal = false">取消</el-button>
        <el-button type="primary" :loading="updating" @click="updateSubmission">更新提交</el-button>
      </template>
    </el-dialog>

    <!-- 查看提交详情弹窗 -->
    <el-dialog v-model="showSubmissionModal" title="提交详情" width="500px">
      <div v-if="submissionDetails" class="submission-details">
        <div class="detail-item">
          <label>作业标题：</label>
          <span>{{ submissionDetails.assignmentTitle }}</span>
        </div>
        <div class="detail-item">
          <label>作业描述：</label>
          <span>{{ submissionDetails.assignmentDescription }}</span>
        </div>
        <div class="detail-item">
          <label>提交时间：</label>
          <span>{{ formatDate(submissionDetails.submittedAt) }}</span>
        </div>
        <div class="detail-item">
          <label>提交文件：</label>
          <button class="download-btn" @click="downloadSubmissionFile(submissionDetails.fileUrl)">
            <i class="fas fa-download"></i> 下载我的提交
          </button>
        </div>
        <div v-if="submissionDetails.feedback" class="detail-item">
          <label>教师反馈：</label>
          <span>{{ submissionDetails.feedback }}</span>
        </div>
        <div v-if="submissionDetails.feedbackTime" class="detail-item">
          <label>反馈时间：</label>
          <span>{{ formatDate(submissionDetails.feedbackTime) }}</span>
        </div>
      </div>
      <template #footer>
        <el-button @click="showSubmissionModal = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElSelect, ElOption, ElTag, ElButton, ElDialog, ElMessageBox } from 'element-plus'
import { useRouter, useRoute } from 'vue-router'
import axios from 'axios'
import config from '@/config'
import 'element-plus/dist/index.css'

const router = useRouter()
const route = useRoute()

// Get class info from route params/query
const classId = ref(route.params.classId)
const className = ref(route.query.className || '班级')
const teacherName = ref(route.query.teacherName || '教师')

const loading = ref(false)
const assignmentList = ref([])
const filterSubmitted = ref(null)

// 上传相关
const showUploadModal = ref(false)
const uploadAssignmentId = ref(null)
const uploadFile = ref(null)
const uploading = ref(false)

// 更新相关
const showUpdateModal = ref(false)
const updateAssignmentId = ref(null)
const updateFile = ref(null)
const updating = ref(false)

// 查看提交详情相关
const showSubmissionModal = ref(false)
const submissionDetails = ref(null)

// 获取指定班级的作业列表
const fetchAssignments = async () => {
  try {
    loading.value = true
    const params = {
      classId: classId.value
    }
    if (filterSubmitted.value !== null) {
      params.submitted = filterSubmitted.value
    }
    
    const response = await axios.get(`${config.baseUrl}/assignments/student`, {
      params,
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('token')}`
      }
    })
    
    // Filter assignments by classId to ensure we only show assignments for this class
    assignmentList.value = response.data.filter(assignment => 
      assignment.classId === parseInt(classId.value)
    )
  } catch (error) {
    console.error('Error fetching assignments:', error)
    ElMessage.error('获取作业列表失败')
  } finally {
    loading.value = false
  }
}

const goBack = () => {
  router.push('/student/home')
}

const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const getDueDateClass = (dueDate) => {
  if (!dueDate) return 'normal'
  
  const now = new Date()
  const due = new Date(dueDate)
  const timeDiff = due.getTime() - now.getTime()
  const daysDiff = timeDiff / (1000 * 3600 * 24)
  
  if (daysDiff < 0) return 'overdue'
  if (daysDiff < 1) return 'urgent'
  if (daysDiff < 3) return 'warning'
  return 'normal'
}

const isOverdue = (dueDate) => {
  if (!dueDate) return false
  return new Date(dueDate) < new Date()
}

const downloadAssignment = (assignment) => {
      const downloadUrl = `${config.baseUrl}/assignments/${assignment.id}/download`
  axios({
    url: downloadUrl,
    method: 'GET',
    responseType: 'blob',
    headers: {
      'Authorization': `Bearer ${localStorage.getItem('token')}`
    }
  }).then((response) => {
    const href = URL.createObjectURL(response.data);
    const link = document.createElement('a');
    link.href = href;
    
    // 从响应头中获取文件名
    const contentDisposition = response.headers['content-disposition'];
    let fileName = `${assignment.title}-instructions.pdf`; // 默认文件名
    
    if (contentDisposition) {
      const fileNameMatch = contentDisposition.match(/filename="(.+)"/);
      if (fileNameMatch) {
        fileName = fileNameMatch[1];
      }
    }
    
    link.setAttribute('download', fileName);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(href);
  }).catch(error => {
    console.error('下载失败:', error);
    ElMessage.error('下载失败，请重试');
  });
}

const openUploadModal = (assignment) => {
  uploadAssignmentId.value = assignment.id
  showUploadModal.value = true
  uploadFile.value = null
}

const handleFileChange = (e) => {
  uploadFile.value = e.target.files[0]
}

const submitAssignment = async () => {
  if (!uploadFile.value) {
    ElMessage.warning('请选择文件')
    return
  }
  uploading.value = true
  try {
    const formData = new FormData()
    formData.append('file', uploadFile.value)
    await axios.post(
      `${config.baseUrl}/assignments/${uploadAssignmentId.value}/submit`,
      formData,
      {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`,
          'Content-Type': 'multipart/form-data'
        }
      }
    )
    ElMessage.success('提交成功')
    showUploadModal.value = false
    fetchAssignments()
  } catch (e) {
    if (e.response?.status === 400) {
      ElMessage.error(e.response.data.message || '提交失败')
    } else {
      ElMessage.error('提交失败')
    }
  } finally {
    uploading.value = false
  }
}

const handleViewSubmission = async (assignment) => {
  try {
    const response = await axios.get(
      `${config.baseUrl}/assignments/${assignment.id}/submission`,
      {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      }
    )
    submissionDetails.value = response.data
    showSubmissionModal.value = true
  } catch (error) {
    ElMessage.error('获取提交详情失败')
    console.error('Error fetching submission details:', error)
  }
}

const downloadSubmissionFile = (fileUrl) => {
      const downloadUrl = `${config.baseUrl}/assignments/download?fileUrl=` + fileUrl
  axios({
    url: downloadUrl,
    method: 'GET',
    responseType: 'blob'
  }).then((response) => {
    const href = URL.createObjectURL(response.data);
    const link = document.createElement('a');
    link.href = href;
    link.setAttribute('download', fileUrl);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(href);
  }).catch(error => {
    ElMessage.error('下载文件失败')
    console.error('Error downloading file:', error)
  })
}

const openUpdateModal = (assignment) => {
  updateAssignmentId.value = assignment.id
  showUpdateModal.value = true
  updateFile.value = null
}

const handleUpdateFileChange = (e) => {
  updateFile.value = e.target.files[0]
}

const updateSubmission = async () => {
  if (!updateFile.value) {
    ElMessage.warning('请选择文件')
    return
  }
  updating.value = true
  try {
    const formData = new FormData()
    formData.append('file', updateFile.value)
    await axios.put(
      `${config.baseUrl}/assignments/${updateAssignmentId.value}/submit`,
      formData,
      {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`,
          'Content-Type': 'multipart/form-data'
        }
      }
    )
    ElMessage.success('更新成功')
    showUpdateModal.value = false
    fetchAssignments()
  } catch (e) {
    ElMessage.error('更新失败')
  } finally {
    updating.value = false
  }
}

const handleUnsubmit = (assignment) => {
  ElMessageBox.confirm(
    '确定要取消提交这个作业吗？此操作将删除您的提交记录。',
    '确认取消提交',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning',
    }
  ).then(async () => {
    try {
      await axios.delete(
        `${config.baseUrl}/assignments/${assignment.id}/unsubmit`,
        {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('token')}`
          }
        }
      )
      ElMessage.success('取消提交成功')
      fetchAssignments()
    } catch (e) {
      ElMessage.error('取消提交失败')
    }
  }).catch(() => {
    // 用户取消操作
  })
}

onMounted(fetchAssignments)
</script>

<style scoped>
.class-assignments {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
  margin-top: 100px;
}

.class-header {
  display: grid;
  grid-template-columns: 1fr 2fr 1fr;
  align-items: center;
  margin-bottom: 30px;
  padding: 20px;
  background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%);
  border-radius: 12px;
  color: white;
}

.back-button {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  padding: 8px 16px;
  border-radius: 8px;
  transition: all 0.3s;
  background: rgba(255, 255, 255, 0.1);
  justify-self: start;
}

.back-button:hover {
  background: rgba(255, 255, 255, 0.2);
}

.class-info {
  text-align: center;
  justify-self: center;
}

.class-info h1 {
  margin: 0 0 5px 0;
  font-size: 2rem;
}

.teacher-info {
  margin: 0;
  opacity: 0.9;
  font-size: 1.1rem;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.section-header h2 {
  margin: 0;
  color: #2c3e50;
}

.assignment-list {
  margin-bottom: 30px;
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
}

.empty-icon {
  font-size: 48px;
  color: #ddd;
  margin-bottom: 20px;
}

.assignment-table {
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

table {
  width: 100%;
  border-collapse: collapse;
  table-layout: fixed;
}

th, td {
  padding: 15px;
  text-align: left;
  border-bottom: 1px solid #eee;
  vertical-align: top;
}

th {
  background-color: #f8f9fa;
  font-weight: 600;
  color: #2c3e50;
}

tr:hover {
  background-color: #f8f9fa;
}

/* Column width definitions for consistent alignment */
.col-title {
  width: 20%;
}

.col-description {
  width: 25%;
}

.col-date {
  width: 12%;
  white-space: nowrap;
}

.col-status {
  width: 10%;
  text-align: center;
}

.col-actions {
  width: 21%;
}

.actions-container {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.action-btn {
  padding: 6px 12px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 5px;
  font-weight: bold;
  transition: all 0.3s;
  font-size: 12px;
  min-height: 32px;
  justify-content: center;
}

.action-btn.submit {
  background: #E8F5E9;
  color: #388E3C;
}

.action-btn.submit:hover {
  background: #C8E6C9;
}

.action-btn.view {
  background: #E3F2FD;
  color: #1976D2;
}

.action-btn.view:hover {
  background: #BBDEFB;
}

.action-btn.download {
  background: #FFF3E0;
  color: #FF9800;
}

.action-btn.download:hover {
  background: #FFE0B2;
}

.submitted-actions {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 5px;
  margin-top: 8px;
}

.action-btn.update {
  background: #2196F3;
  color: white;
}

.action-btn.update:hover {
  background: #1976D2;
}

.action-btn.unsubmit {
  background: #f44336;
  color: white;
}

.action-btn.unsubmit:hover {
  background: #d32f2f;
}

/* Responsive button text for smaller buttons */
.submitted-actions .action-btn {
  font-size: 11px;
  padding: 5px 8px;
  min-height: 28px;
}

.submitted-actions .action-btn i {
  font-size: 10px;
}

.action-btn.disabled {
  background: #f5f5f5;
  color: #999;
  cursor: not-allowed;
}

.action-btn.disabled:hover {
  background: #f5f5f5;
}

.update-modal-content {
  padding: 10px 0;
}

.update-modal-content p {
  margin-bottom: 15px;
  color: #666;
}

.submission-details {
  padding: 10px 0;
}

.detail-item {
  display: flex;
  margin-bottom: 15px;
  align-items: flex-start;
}

.detail-item label {
  font-weight: bold;
  min-width: 100px;
  color: #333;
}

.detail-item span {
  flex: 1;
  color: #666;
  word-break: break-word;
}

.download-btn {
  background: #4CAF50;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 4px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 14px;
}

.download-btn:hover {
  background: #45a049;
}

/* Due date styling */
.overdue {
  color: #d32f2f;
  font-weight: bold;
}

.urgent {
  color: #ff5722;
  font-weight: bold;
}

.warning {
  color: #ff9800;
  font-weight: bold;
}

.normal {
  color: #4caf50;
}

.no-due-date {
  color: #999;
  font-style: italic;
}
</style> 