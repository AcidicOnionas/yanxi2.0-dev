package com.yanxi.yanxiapi.controller;

import com.yanxi.yanxiapi.entity.Assignment;
import com.yanxi.yanxiapi.entity.User;
import com.yanxi.yanxiapi.service.AssignmentService;
import com.yanxi.yanxiapi.service.FileService;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@RestController
@RequestMapping("/api/assignments")
@RequiredArgsConstructor
public class AssignmentController {
    private final AssignmentService assignmentService;
    private final FileService fileService;

    @GetMapping
    public ResponseEntity<List<Assignment>> getAssignments(
            @RequestParam(name = "classId", required = false) Long classId,
            @RequestParam(name = "studentEmail", required = false) String studentEmail,
            @AuthenticationPrincipal User teacher) {
        List<Assignment> assignments = assignmentService.getAssignments(classId, studentEmail, teacher);
        return ResponseEntity.ok(assignments);
    }

    /**
     *  创建作业
     * @param classId
     * @param title
     * @param description
     * @param file
     * @param dueDate
     * @param teacher
     * @return
     */
    @PostMapping
    public ResponseEntity<Assignment> createAssignment(
            @RequestParam("classId") Long classId,
            @RequestParam("title") String title,
            @RequestParam("description") String description,
            @RequestParam("file") MultipartFile file,
            @RequestParam("dueDate") String dueDate,
            @AuthenticationPrincipal User teacher) {
        
        LocalDateTime dueDateTime = LocalDateTime.parse(dueDate, DateTimeFormatter.ISO_LOCAL_DATE_TIME);
        Assignment assignment = assignmentService.createAssignment(classId, title, description, file, dueDateTime, teacher);
        return ResponseEntity.ok(assignment);
    }

    @GetMapping("/download")
    public ResponseEntity<Resource> downloadFile(@RequestParam String fileUrl) {
        try {
            Resource resource = fileService.loadFileAsResource(fileUrl);
            
            String contentType = "application/octet-stream";
            String headerValue = "attachment; filename=\"" + resource.getFilename() + "\"";

            return ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType(contentType))
                    .header(HttpHeaders.CONTENT_DISPOSITION, headerValue)
                    .body(resource);
        } catch (IOException e) {
            return ResponseEntity.notFound().build();
        }
    }

    /**
     * 获取作业的学生列表
     * @param assignmentId 作业ID
     * @return 学生列表
     */
    @GetMapping("/{assignmentId}/students")
    public ResponseEntity<List<User>> getAssignmentStudents(@PathVariable Long assignmentId) {
        List<User> students = assignmentService.getAssignmentStudents(assignmentId);
        return ResponseEntity.ok(students);
    }

    /**
     * 获取当前学生的作业列表
     * @param submitted 是否已提交（可选）
     * @param student 当前登录的学生
     * @return 作业列表
     */
    @GetMapping("/student")
    public ResponseEntity<List<Assignment>> getStudentAssignments(
            @RequestParam(value = "submitted", required = false) Boolean submitted,
            @AuthenticationPrincipal User student) {
        List<Assignment> assignments = assignmentService.getStudentAssignments(submitted, student);
        return ResponseEntity.ok(assignments);
    }

    /**
     * 学生提交作业
     * @param assignmentId 作业ID
     * @param file 作业文件
     * @param student 当前登录的学生
     * @return 更新后的作业信息
     */
    @PostMapping("/{assignmentId}/submit")
    public ResponseEntity<Assignment> submitAssignment(
            @PathVariable Long assignmentId,
            @RequestParam("file") MultipartFile file,
            @AuthenticationPrincipal User student) {
        Assignment assignment = assignmentService.submitAssignment(assignmentId, file, student);
        return ResponseEntity.ok(assignment);
    }
} 