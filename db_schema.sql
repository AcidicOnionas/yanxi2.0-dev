-- 用户表
CREATE TABLE `user` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
  `username` VARCHAR(50) NOT NULL COMMENT '用户名',
  `password` VARCHAR(255) NOT NULL COMMENT '密码（加密）',
  `role` ENUM('teacher','student') NOT NULL COMMENT '角色',
  `real_name` VARCHAR(100) COMMENT '真实姓名',
  `email` VARCHAR(100) NOT NULL COMMENT '邮箱',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  UNIQUE KEY `uk_user_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 班级表
CREATE TABLE `class` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '班级ID',
  `name` VARCHAR(100) NOT NULL COMMENT '班级名称',
  `code` VARCHAR(20) NOT NULL COMMENT '班级邀请码/编码',
  `teacher_id` BIGINT NOT NULL COMMENT '班主任ID',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  FOREIGN KEY (`teacher_id`) REFERENCES `user`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='班级表';

-- 班级-学生关联表
CREATE TABLE `class_student` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
  `class_id` BIGINT NOT NULL COMMENT '班级ID',
  `student_id` BIGINT NOT NULL COMMENT '学生ID',
  `joined_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '加入时间',
  FOREIGN KEY (`class_id`) REFERENCES `class`(`id`),
  FOREIGN KEY (`student_id`) REFERENCES `user`(`id`),
  UNIQUE KEY `uk_class_student` (`class_id`, `student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='班级-学生关联表';

-- 作业表
CREATE TABLE `assignment` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '作业ID',
  `title` VARCHAR(200) NOT NULL COMMENT '作业标题',
  `description` TEXT COMMENT '作业描述',
  `class_id` BIGINT NOT NULL COMMENT '班级ID',
  `teacher_id` BIGINT NOT NULL COMMENT '发布老师ID',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  `due_date` DATETIME COMMENT '截止时间',
  FOREIGN KEY (`class_id`) REFERENCES `class`(`id`),
  FOREIGN KEY (`teacher_id`) REFERENCES `user`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='作业表';

-- 作业提交表
CREATE TABLE `assignment_submission` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '提交ID',
  `assignment_id` BIGINT NOT NULL COMMENT '作业ID',
  `student_id` BIGINT NOT NULL COMMENT '学生ID',
  `file_url` VARCHAR(255) NOT NULL COMMENT '上传文件地址',
  `submitted_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
  `feedback` TEXT COMMENT '老师反馈',
  `feedback_time` DATETIME COMMENT '反馈时间',
  FOREIGN KEY (`assignment_id`) REFERENCES `assignment`(`id`),
  FOREIGN KEY (`student_id`) REFERENCES `user`(`id`),
  INDEX `idx_assignment_student` (`assignment_id`, `student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='作业提交表'; 