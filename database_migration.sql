-- =====================================================
-- Yanxi Education Platform Database Migration Script
-- =====================================================

-- Drop existing tables if they exist (in reverse order due to foreign keys)
DROP TABLE IF EXISTS `assignment_submission`;
DROP TABLE IF EXISTS `assignment`;
DROP TABLE IF EXISTS `class_student`;
DROP TABLE IF EXISTS `class`;
DROP TABLE IF EXISTS `user`;

-- =====================================================
-- 1. User Table (用户表)
-- =====================================================
CREATE TABLE `user` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
  `username` VARCHAR(50) NOT NULL COMMENT '用户名',
  `password` VARCHAR(255) NOT NULL COMMENT '密码（加密）',
  `role` ENUM('TEACHER','STUDENT') NOT NULL COMMENT '角色：TEACHER-教师，STUDENT-学生',
  `real_name` VARCHAR(100) COMMENT '真实姓名',
  `email` VARCHAR(100) NOT NULL COMMENT '邮箱',
  `phone` VARCHAR(20) COMMENT '手机号',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  UNIQUE KEY `uk_user_email` (`email`),
  UNIQUE KEY `uk_user_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- =====================================================
-- 2. Class Table (班级表)
-- =====================================================
CREATE TABLE `class` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '班级ID',
  `name` VARCHAR(100) NOT NULL COMMENT '班级名称',
  `code` VARCHAR(20) NOT NULL COMMENT '班级邀请码/编码',
  `description` TEXT COMMENT '班级描述',
  `teacher_id` BIGINT NOT NULL COMMENT '班主任ID',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  UNIQUE KEY `uk_class_code` (`code`),
  FOREIGN KEY (`teacher_id`) REFERENCES `user`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='班级表';

-- =====================================================
-- 3. Class-Student Association Table (班级-学生关联表)
-- =====================================================
CREATE TABLE `class_student` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
  `class_id` BIGINT NOT NULL COMMENT '班级ID',
  `student_id` BIGINT NOT NULL COMMENT '学生ID',
  `joined_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '加入时间',
  FOREIGN KEY (`class_id`) REFERENCES `class`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`student_id`) REFERENCES `user`(`id`) ON DELETE CASCADE,
  UNIQUE KEY `uk_class_student` (`class_id`, `student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='班级-学生关联表';

-- =====================================================
-- 4. Assignment Table (作业表)
-- =====================================================
CREATE TABLE `assignment` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '作业ID',
  `title` VARCHAR(200) NOT NULL COMMENT '作业标题',
  `description` TEXT COMMENT '作业描述',
  `class_id` BIGINT NOT NULL COMMENT '班级ID',
  `teacher_id` BIGINT NOT NULL COMMENT '发布老师ID',
  `file_url` VARCHAR(500) COMMENT '作业附件文件URL',
  `due_date` DATETIME COMMENT '截止时间',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  FOREIGN KEY (`class_id`) REFERENCES `class`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`teacher_id`) REFERENCES `user`(`id`) ON DELETE CASCADE,
  INDEX `idx_assignment_class` (`class_id`),
  INDEX `idx_assignment_teacher` (`teacher_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='作业表';

-- =====================================================
-- 5. Assignment Submission Table (作业提交表)
-- =====================================================
CREATE TABLE `assignment_submission` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '提交ID',
  `assignment_id` BIGINT NOT NULL COMMENT '作业ID',
  `student_id` BIGINT NOT NULL COMMENT '学生ID',
  `file_url` VARCHAR(500) NOT NULL COMMENT '上传文件地址',
  `submitted_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
  `feedback` TEXT COMMENT '老师反馈',
  `feedback_time` DATETIME COMMENT '反馈时间',
  `grade` DECIMAL(5,2) COMMENT '成绩',
  FOREIGN KEY (`assignment_id`) REFERENCES `assignment`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`student_id`) REFERENCES `user`(`id`) ON DELETE CASCADE,
  UNIQUE KEY `uk_assignment_student` (`assignment_id`, `student_id`),
  INDEX `idx_submission_assignment` (`assignment_id`),
  INDEX `idx_submission_student` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='作业提交表';

-- =====================================================
-- Sample Data for Testing (Optional)
-- =====================================================

-- Insert sample teacher
INSERT INTO `user` (`username`, `password`, `role`, `real_name`, `email`, `phone`) VALUES
('teacher1', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9P8jEeOxrOHsQ.m', 'TEACHER', 'Zhang Laoshi', 'teacher@yanxi.edu', '13800138000'),
('student1', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9P8jEeOxrOHsQ.m', 'STUDENT', 'Li Ming', 'student1@yanxi.edu', '13800138001'),
('student2', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9P8jEeOxrOHsQ.m', 'STUDENT', 'Wang Xiaoli', 'student2@yanxi.edu', '13800138002');

-- Insert sample class
INSERT INTO `class` (`name`, `code`, `description`, `teacher_id`) VALUES
('语文1班', 'YW001', '高中语文基础班', 1),
('数学1班', 'SX001', '高中数学提高班', 1);

-- Insert sample class-student relationships
INSERT INTO `class_student` (`class_id`, `student_id`) VALUES
(1, 2), (1, 3), (2, 2);

-- Insert sample assignment
INSERT INTO `assignment` (`title`, `description`, `class_id`, `teacher_id`, `due_date`) VALUES
('古诗词背诵作业', '背诵《静夜思》并录制视频', 1, 1, DATE_ADD(NOW(), INTERVAL 7 DAY)),
('数学练习题', '完成教材第3章练习题1-20', 2, 1, DATE_ADD(NOW(), INTERVAL 5 DAY));

-- =====================================================
-- Indexes for Performance Optimization
-- =====================================================

-- Additional indexes for common queries
CREATE INDEX `idx_user_role` ON `user`(`role`);
CREATE INDEX `idx_class_teacher` ON `class`(`teacher_id`);
CREATE INDEX `idx_assignment_due_date` ON `assignment`(`due_date`);
CREATE INDEX `idx_submission_submitted_at` ON `assignment_submission`(`submitted_at`);

-- =====================================================
-- Views for Common Queries (Optional)
-- =====================================================

-- View for class with student count
CREATE VIEW `class_with_stats` AS
SELECT 
    c.`id`,
    c.`name`,
    c.`code`,
    c.`description`,
    c.`teacher_id`,
    u.`real_name` AS `teacher_name`,
    c.`created_at`,
    COUNT(cs.`student_id`) AS `student_count`
FROM `class` c
LEFT JOIN `user` u ON c.`teacher_id` = u.`id`
LEFT JOIN `class_student` cs ON c.`id` = cs.`class_id`
GROUP BY c.`id`, c.`name`, c.`code`, c.`description`, c.`teacher_id`, u.`real_name`, c.`created_at`;

-- View for assignments with submission stats
CREATE VIEW `assignment_with_stats` AS
SELECT 
    a.`id`,
    a.`title`,
    a.`description`,
    a.`class_id`,
    c.`name` AS `class_name`,
    a.`teacher_id`,
    u.`real_name` AS `teacher_name`,
    a.`file_url`,
    a.`due_date`,
    a.`created_at`,
    COUNT(asub.`id`) AS `submission_count`
FROM `assignment` a
LEFT JOIN `class` c ON a.`class_id` = c.`id`
LEFT JOIN `user` u ON a.`teacher_id` = u.`id`
LEFT JOIN `assignment_submission` asub ON a.`id` = asub.`assignment_id`
GROUP BY a.`id`, a.`title`, a.`description`, a.`class_id`, c.`name`, a.`teacher_id`, u.`real_name`, a.`file_url`, a.`due_date`, a.`created_at`;

-- =====================================================
-- Migration Complete
-- =====================================================
-- This script creates a complete database structure for the Yanxi Education Platform
-- 
-- Features included:
-- 1. User management (teachers and students)
-- 2. Class management with invitation codes
-- 3. Class-student relationships
-- 4. Assignment creation and management
-- 5. Assignment submission tracking
-- 6. Performance optimized with proper indexes
-- 7. Sample data for testing
-- 8. Useful views for common queries
-- 
-- Password for sample users: "password123" (bcrypt encoded)
-- ===================================================== 