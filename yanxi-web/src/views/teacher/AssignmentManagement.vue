<template>
    <div class="assignment-management">
      <div class="header-actions">
        <h2></h2>
        <div class="filters">
          <select v-model="filterForm.classId" @change="handleFilter" class="class-select">
            <option value="">所有班级</option>
            <option v-for="item in classList" :key="item.id" :value="item.id">
              {{ item.name }}
            </option>
          </select>
          <div class="search-box">
            <input 
              type="text" 
              v-model="filterForm.studentEmail" 
              placeholder="按学生邮箱搜索..."
              @input="handleFilter"
            />
          </div>
        </div>
      </div>
  
      <div class="assignment-list">
        <div v-if="loading" class="loading">加载作业中...</div>
        <div v-else-if="assignmentList.length === 0" class="empty-state">
          暂无作业数据
        </div>
        <div v-else class="assignment-table">
          <table>
            <thead>
              <tr>
                <th>作业标题</th>
                <th>作业描述</th>
                <th>班级名称</th>
                <th>创建时间</th>
                <!-- <th>附件</th> -->
                <th>操作</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="assignment in assignmentList" :key="assignment.id">
                <td>{{ assignment.title }}</td>
                <td>{{ assignment.description }}</td>
                <td>{{ getClassName(assignment.classId) }}</td>
                <td>{{ formatDate(assignment.createdAt) }}</td>
                <td class="actions">
                  <button class="action-btn edit" @click="handleEdit(assignment)">
                    <i class="fas fa-edit"></i> 编辑
                  </button>
                  <button class="action-btn view" @click="handleViewStudents(assignment)">
                    <i class="fas fa-download"></i> 上传详情
                  </button>
                  <button class="action-btn delete" @click="handleDelete(assignment)">
                    <i class="fas fa-trash"></i> 删除
                  </button>
                </td>
              </tr>
              <!-- 展开的详情行 -->
              <tr v-if="currentAssignment" class="detail-row">
                <td colspan="5">
                  <div class="detail-content">
                    <div class="detail-header">
                      <h3>作业提交详情</h3>
                      <button class="close-btn" @click="handleCloseDetail">×</button>
                    </div>
                    <div v-if="loadingStudents" class="loading">加载学生列表中...</div>
                    <div v-else-if="!studentList || studentList.length === 0" class="empty-state">
                      暂无学生数据
                    </div>
                    <div v-else class="student-table">
                      <table>
                        <thead>
                          <tr>
                            <th>学生姓名</th>
                            <th>邮箱</th>
                            <th>提交状态</th>
                            <th>提交时间</th>
                            <th>操作</th>
                          </tr>
                        </thead>
                        <tbody>
                          <tr v-for="student in studentList" :key="student.id">
                            <td>{{ student.username }}</td>
                            <td>{{ student.email }}</td>
                            <td>
                              <el-tag :type="student.submitted ? 'success' : 'warning'">
                                {{ student.submitted ? '已提交' : '未提交' }}
                              </el-tag>
                            </td>
                            <td>{{ student.submitted ? formatDate(student.submittedAt) : '-' }}</td>
                            <td>
                              <el-button 
                                type="primary" 
                                size="small"
                                v-if="student.submitted"
                                @click="handleDownloadSubmission(student)"
                              >
                                下载作业
                              </el-button>
                            </td>
                          </tr>
                        </tbody>
                      </table>
                    </div>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
  
      <!-- 编辑作业对话框 -->
      <el-dialog 
        v-model="dialogVisible" 
        :title="editForm.id ? '编辑作业' : '发布新作业'" 
        width="50%"
      >
        <el-form :model="editForm" label-width="100px" :rules="rules" ref="editFormRef">
          <el-form-item label="作业标题" prop="title">
            <el-input v-model="editForm.title" />
          </el-form-item>
          <el-form-item label="作业描述" prop="description">
            <el-input type="textarea" v-model="editForm.description" :rows="4" />
          </el-form-item>
          <el-form-item label="班级" prop="classId">
            <el-select v-model="editForm.classId" placeholder="选择班级">
              <el-option
                v-for="item in classList"
                :key="item.id"
                :label="item.name"
                :value="item.id"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="截止日期" prop="dueDate">
            <el-date-picker
              v-model="editForm.dueDate"
              type="datetime"
              placeholder="选择截止日期"
              format="YYYY-MM-DD HH:mm:ss"
              value-format="YYYY-MM-DD HH:mm:ss"
              style="width: 100%"
              clearable
              :disabled-date="disabledDate"
            />
            <div style="margin-top: 5px; color: #909399; font-size: 12px;">
              请选择作业的截止时间（不能选择过去的日期）
            </div>
          </el-form-item>
          <el-form-item label="附件">
            <el-upload
              class="upload-demo"
              :auto-upload="false"
              :on-change="handleFileChange"
              :before-upload="beforeUpload"
              :limit="1"
              :file-list="fileList"
            >
              <el-button type="primary">选择文件</el-button>
              <template #tip>
                <div class="el-upload__tip">
                  支持上传 .pdf, .doc, .docx, .txt 文件，且不超过 10MB
                </div>
              </template>
            </el-upload>
          </el-form-item>
        </el-form>
        <template #footer>
          <span class="dialog-footer">
            <el-button @click="dialogVisible = false">取消</el-button>
            <el-button type="primary" @click="handleSave">保存</el-button>
          </span>
        </template>
      </el-dialog>
  
      <!-- 学生列表对话框 -->
      <el-dialog 
        v-model="studentDialogVisible" 
        title="作业提交详情" 
        width="60%"
        @opened="handleDialogOpened"
        @closed="handleDialogClosed"
      >
        <template v-if="currentAssignment">
          <div v-if="loadingStudents" class="loading">加载学生列表中...</div>
          <div v-else-if="studentList.length === 0" class="empty-state">
            暂无学生数据
          </div>
          <div v-else class="student-table">
            <table>
              <thead>
                <tr>
                  <th>学生姓名</th>
                  <th>邮箱</th>
                  <th>提交状态</th>
                  <th>提交时间</th>
                  <th>操作</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="student in studentList" :key="student.id">
                  <td>{{ student.username }}</td>
                  <td>{{ student.email }}</td>
                  <td>
                    <el-tag :type="student.submitted ? 'success' : 'warning'">
                      {{ student.submitted ? '已提交' : '未提交' }}
                    </el-tag>
                  </td>
                  <td>{{ student.submitted ? formatDate(student.submittedAt) : '-' }}</td>
                  <td>
                    <el-button 
                      type="primary" 
                      size="small"
                      v-if="student.submitted"
                      @click="handleDownloadSubmission(student)"
                    >
                      下载作业
                    </el-button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </template>
      </el-dialog>


    </div>
  </template>
  
  <script setup>
  import { ref, onMounted, watch } from 'vue'
  import { ElMessage, ElMessageBox } from 'element-plus'
  import axios from 'axios'
import config from '@/config'
  
  const loading = ref(false)
  const dialogVisible = ref(false)
  const assignmentList = ref([])
  const classList = ref([])
  const studentList = ref([])
  const editFormRef = ref(null)

  const studentDialogVisible = ref(false)
  const loadingStudents = ref(false)
  const currentAssignment = ref(null)
  const currentFile = ref(null)
  const fileList = ref([])
  
  const filterForm = ref({
    classId: '',
    studentEmail: ''
  })
  
  const editForm = ref({
    id: null,
    title: '',
    description: '',
    classId: '',
    dueDate: null,
    fileUrl: ''
  })
  
  const rules = {
    title: [{ required: true, message: '请输入作业标题', trigger: 'blur' }],
    description: [{ required: true, message: '请输入作业描述', trigger: 'blur' }],
    classId: [{ required: true, message: '请选择班级', trigger: 'change' }],
    dueDate: [{ required: true, message: '请选择截止日期', trigger: 'change' }]
  }


  

  
  // 获取作业列表
  const fetchAssignments = async () => {
    try {
      loading.value = true
      const response = await axios.get(`${config.baseUrl}/assignments`, {
        params: filterForm.value,
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      })
      assignmentList.value = response.data || []
    } catch (error) {
      console.error('获取作业列表失败:', error)
      ElMessage.error('获取作业列表失败')
      assignmentList.value = []
    } finally {
      loading.value = false
    }
  }
  
  // 获取班级列表
  const fetchClasses = async () => {
    try {
      const response = await axios.get(`${config.baseUrl}/classes/teacher`, {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      })
      classList.value = response.data || []
    } catch (error) {
      console.error('获取班级列表失败:', error)
      ElMessage.error('获取班级列表失败')
      classList.value = []
    }
  }
  
  // 获取学生列表
  const fetchStudents = async () => {
    try {
      const response = await axios.get(`${config.baseUrl}/classes/teacher/students`, {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      })
      studentList.value = response.data || []
    } catch (error) {
      console.error('获取学生列表失败:', error)
      ElMessage.error('获取学生列表失败')
      studentList.value = []
    }
  }
  
  // 处理筛选
  const handleFilter = () => {
    fetchAssignments()
  }
  
  // 处理添加
  const handleAdd = () => {
    editForm.value = {
      id: null,
      title: '',
      description: '',
      classId: '',
      dueDate: null,
      fileUrl: ''
    }
    currentFile.value = null
    fileList.value = []
    dialogVisible.value = true
  }
  
  // 处理编辑
  const handleEdit = (row) => {
    editForm.value = { ...row }
    dialogVisible.value = true
  }
  
  // 处理删除
  const handleDelete = async (row) => {
    try {
      await ElMessageBox.confirm('确定要删除这个作业吗？', '提示', {
        type: 'warning'
      })
      await axios.delete(`${config.baseUrl}/assignments/${row.id}`, {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      })
      ElMessage.success('删除成功')
      fetchAssignments()
    } catch (error) {
      if (error !== 'cancel') {
        console.error('删除作业失败:', error)
        ElMessage.error('删除失败: ' + (error.response?.data?.message || error.message))
      }
    }
  }
  
  // 处理保存
  const handleSave = async () => {
    if (!editFormRef.value) return
    
    try {
      await editFormRef.value.validate()
      
      if (editForm.value.id) {
        // 编辑作业 - 暂时不支持
        ElMessage.warning('暂不支持编辑作业功能')
        return
      }
      
      // 创建新作业
      if (!currentFile.value) {
        ElMessage.error('请先选择作业文件')
        return
      }
      
      // 验证截止日期
      if (!editForm.value.dueDate) {
        ElMessage.error('请选择截止日期')
        return
      }
      
      const formData = new FormData()
      formData.append('classId', editForm.value.classId)
      formData.append('title', editForm.value.title)
      formData.append('description', editForm.value.description)
      
      // 格式化日期为 ISO_LOCAL_DATE_TIME 格式 (YYYY-MM-DDTHH:mm:ss)
      const dueDateStr = editForm.value.dueDate.replace(' ', 'T')
      formData.append('dueDate', dueDateStr)
      formData.append('file', currentFile.value)
      
      // 调试信息
      console.log('FormData contents:')
      for (let [key, value] of formData.entries()) {
        console.log(key, value)
      }
      
      await axios.post(`${config.baseUrl}/assignments`, formData, {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`,
          'Content-Type': 'multipart/form-data'
        }
      })
      
      ElMessage.success('发布成功')
      dialogVisible.value = false
      fetchAssignments()
    } catch (error) {
      console.error('保存作业失败:', error)
      ElMessage.error('保存失败: ' + (error.response?.data?.message || error.message))
    }
  }
  
  // 处理文件选择
  const handleFileChange = (file, fileListParam) => {
    currentFile.value = file.raw
    editForm.value.fileUrl = file.name
    fileList.value = fileListParam
    ElMessage.success('文件选择成功')
  }
  
  // 上传前检查
  const beforeUpload = (file) => {
    const isLt10M = file.size / 1024 / 1024 < 10
    if (!isLt10M) {
      ElMessage.error('文件大小不能超过 10MB!')
      return false
    }
    
    const allowedTypes = ['.pdf', '.doc', '.docx', '.txt']
    const fileName = file.name.toLowerCase()
    const isValidType = allowedTypes.some(type => fileName.endsWith(type))
    if (!isValidType) {
      ElMessage.error('只支持上传 .pdf, .doc, .docx, .txt 格式的文件!')
      return false
    }
    
    return true
  }
  
  // 格式化日期
  const formatDate = (date) => {
    if (!date) return ''
    try {
      return new Date(date).toLocaleString('zh-CN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
      })
    } catch (error) {
      console.error('日期格式化错误:', error)
      return date
    }
  }
  
  // 获取班级名称
  const getClassName = (classId) => {
    const classItem = classList.value.find(item => item.id === classId)
    return classItem ? classItem.name : '未知班级'
  }
  
  // 查看学生列表
  const handleViewStudents = async (assignment) => {
    try {
      // 如果点击的是当前展开的作业，则关闭详情
      // if (currentAssignment.value && currentAssignment.value.id === assignment.id) {
      //   handleCloseDetail()
      //   return
      // }
      
      loadingStudents.value = true
      studentList.value = [] // 清空之前的数据
      currentAssignment.value = assignment
      
      const response = await axios.get(`${config.baseUrl}/assignments/${assignment.id}/students`, {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      })
      studentList.value = response.data || []
      console.log(currentAssignment.value)
      console.log(assignment)
    } catch (error) {
      console.error('获取学生列表失败:', error)
      ElMessage.error('获取学生列表失败')
      handleCloseDetail()
    } finally {
      loadingStudents.value = false
    }
  }
  
  // 对话框打开后加载数据
  const handleDialogOpened = () => {
    // 对话框打开时不需要重新加载数据，因为数据已经在点击按钮时加载完成
  }
  
  // 对话框关闭时清空数据
  const handleDialogClosed = () => {
    studentList.value = []
    currentAssignment.value = null
    loadingStudents.value = false
  }
  


  // 下载学生提交的作业
  const handleDownloadSubmission = (student) => {
    if (!currentAssignment.value) {
      ElMessage.error('无法获取作业信息')
      return
    }
    
    const downloadUrl = `${config.baseUrl}/assignments/${currentAssignment.value.id}/download/${student.id}`
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
      
      // 从响应头中获取文件名，如果没有则使用默认格式
      const contentDisposition = response.headers['content-disposition'];
      let fileName = `${student.username}-${currentAssignment.value.title}.pdf`; // 默认文件名
      
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
  
  // 禁用过去的日期
  const disabledDate = (time) => {
    return time.getTime() < Date.now() - 8.64e7
  }
  
  // 关闭详情
  const handleCloseDetail = () => {
    currentAssignment.value = null
    studentList.value = []
    loadingStudents.value = false
  }
  
  onMounted(() => {
    fetchAssignments()
    fetchClasses()
  })
  </script>
  
  <style scoped>
  .assignment-management {
    padding: 20px;
  }
  
  .header-actions {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 30px;
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
  
  .assignment-table {
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
  
  .action-btn.edit {
    background: #E8F5E9;
    color: #388E3C;
  }
  
  .action-btn.edit:hover {
    background: #C8E6C9;
  }
  
  .action-btn.delete {
    background: #FFEBEE;
    color: #D32F2F;
  }
  
  .action-btn.delete:hover {
    background: #FFCDD2;
  }
  
  .action-btn.view {
    background: #E3F2FD;
    color: #1976D2;
  }
  
  .action-btn.view:hover {
    background: #BBDEFB;
  }
  
  .loading,
  .empty-state {
    text-align: center;
    padding: 40px;
    color: #666;
  }
  
  .upload-demo {
    width: 100%;
  }
  
  .el-upload__tip {
    margin-top: 5px;
    color: #909399;
  }
  
  .download-btn {
    display: flex;
    align-items: center;
    gap: 5px;
    background: #409EFF;
    border: none;
    transition: all 0.3s ease;
  }
  
  .download-btn:hover {
    background: #66b1ff;
    transform: translateY(-1px);
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  }
  
  .download-btn i {
    font-size: 14px;
  }
  
  .student-table {
    background: white;
    border-radius: 12px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    overflow: hidden;
    margin-top: 20px;
  }
  
  .student-table table {
    width: 100%;
    border-collapse: collapse;
  }
  
  .student-table th,
  .student-table td {
    padding: 12px;
    text-align: left;
    border-bottom: 1px solid #eee;
  }
  
  .student-table th {
    background-color: #f8f9fa;
    font-weight: 600;
    color: #2c3e50;
  }
  
  .student-table tr:hover {
    background-color: #f8f9fa;
  }
  
  .detail-row {
    background-color: #f8f9fa;
  }
  
  .detail-content {
    padding: 20px;
    background: white;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    margin: 10px;
  }
  
  .detail-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    padding-bottom: 10px;
    border-bottom: 1px solid #eee;
  }
  
  .detail-header h3 {
    margin: 0;
    color: #2c3e50;
    font-size: 1.2rem;
  }
  
  .close-btn {
    background: none;
    border: none;
    font-size: 1.5rem;
    color: #666;
    cursor: pointer;
    padding: 0 5px;
    line-height: 1;
  }
  
  .close-btn:hover {
    color: #333;
  }
  
  .student-table {
    margin-top: 0;
  }
  
  /* 确保表单元素正确显示 */
  .el-form-item {
    margin-bottom: 20px;
  }
  
  .el-date-picker {
    width: 100%;
  }
  
  .el-select {
    width: 100%;
  }
  
  .el-input {
    width: 100%;
  }
  
  .el-textarea {
    width: 100%;
  }


  </style>