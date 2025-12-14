-- ============================================
-- 外卖管理系统数据库初始化脚本
-- 数据库版本: MySQL 8.0+
-- 字符集: utf8mb4
-- 排序规则: utf8mb4_unicode_ci
-- ============================================

-- 创建数据库
DROP DATABASE IF EXISTS `deliver_management`;
CREATE DATABASE `deliver_management` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `deliver_management`;

-- ============================================
-- 1. 分店表（branch）- 多分店管理表
-- ============================================
CREATE TABLE `branch` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '分店ID',
    `name` VARCHAR(64) NOT NULL COMMENT '分店名称',
    `address` VARCHAR(255) NOT NULL COMMENT '分店地址',
    `contact_name` VARCHAR(32) NOT NULL COMMENT '联系人',
    `contact_phone` VARCHAR(11) NOT NULL COMMENT '联系人手机号',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '分店状态：1-启用 0-禁用',
    `is_deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '软删除标识：1-已删 0-未删',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
    `create_user` BIGINT NOT NULL DEFAULT 1 COMMENT '创建人ID',
    `update_user` BIGINT NOT NULL DEFAULT 1 COMMENT '最后修改人ID',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_branch_name` (`name`),
    KEY `idx_branch_status` (`status`),
    KEY `idx_branch_deleted` (`is_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='分店表';

-- ============================================
-- 2. 角色表（role）- 权限控制核心表
-- ============================================
CREATE TABLE `role` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '角色ID',
    `name` VARCHAR(32) NOT NULL COMMENT '角色名称',
    `description` VARCHAR(128) DEFAULT NULL COMMENT '角色描述',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '角色状态：1-启用 0-禁用',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
    `create_user` BIGINT NOT NULL DEFAULT 1 COMMENT '创建人ID',
    `update_user` BIGINT NOT NULL DEFAULT 1 COMMENT '最后修改人ID',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_role_name` (`name`),
    KEY `idx_role_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色表';

-- ============================================
-- 3. 员工表（employee）- 核心管理端用户表
-- ============================================
CREATE TABLE `employee` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '员工ID',
    `username` VARCHAR(32) NOT NULL COMMENT '用户名',
    `password` VARCHAR(64) NOT NULL COMMENT '密码（BCrypt加密）',
    `name` VARCHAR(32) NOT NULL COMMENT '员工姓名',
    `phone` VARCHAR(11) NOT NULL COMMENT '手机号',
    `sex` VARCHAR(4) DEFAULT NULL COMMENT '性别：男/女/未知',
    `id_number` VARCHAR(18) DEFAULT NULL COMMENT '身份证号（加密存储）',
    `role_id` BIGINT NOT NULL COMMENT '角色ID',
    `branch_id` BIGINT NOT NULL COMMENT '分店ID',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '账号状态：1-正常 0-锁定',
    `is_deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '软删除标识：1-已删 0-未删',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
    `create_user` BIGINT NOT NULL DEFAULT 1 COMMENT '创建人ID',
    `update_user` BIGINT NOT NULL DEFAULT 1 COMMENT '最后修改人ID',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_emp_username` (`username`),
    UNIQUE KEY `uk_emp_phone` (`phone`),
    KEY `idx_emp_role_branch_status` (`role_id`, `branch_id`, `status`),
    KEY `idx_emp_deleted` (`is_deleted`),
    CONSTRAINT `fk_emp_role` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`) ON UPDATE CASCADE,
    CONSTRAINT `fk_emp_branch` FOREIGN KEY (`branch_id`) REFERENCES `branch` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='员工表';

-- ============================================
-- 4. 权限表（permission）- 菜单/按钮权限表
-- ============================================
CREATE TABLE `permission` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '权限ID',
    `name` VARCHAR(32) NOT NULL COMMENT '权限名称',
    `type` TINYINT NOT NULL COMMENT '权限类型：1-菜单权限 2-按钮权限',
    `path` VARCHAR(64) DEFAULT NULL COMMENT '路由路径/按钮标识',
    `parent_id` BIGINT DEFAULT NULL COMMENT '父权限ID',
    `sort` INT NOT NULL DEFAULT 0 COMMENT '排序值',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '权限状态：1-启用 0-禁用',
    PRIMARY KEY (`id`),
    KEY `idx_permission_type` (`type`),
    KEY `idx_permission_parent` (`parent_id`),
    KEY `idx_permission_status` (`status`),
    CONSTRAINT `fk_permission_parent` FOREIGN KEY (`parent_id`) REFERENCES `permission` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='权限表';

-- ============================================
-- 5. 角色权限关联表（role_permission）- 多对多关联
-- ============================================
CREATE TABLE `role_permission` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '关联ID',
    `role_id` BIGINT NOT NULL COMMENT '角色ID',
    `permission_id` BIGINT NOT NULL COMMENT '权限ID',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_role_permission` (`role_id`, `permission_id`),
    CONSTRAINT `fk_rp_role` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_rp_permission` FOREIGN KEY (`permission_id`) REFERENCES `permission` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色权限关联表';

-- ============================================
-- 6. 分类表（category）- 菜品/套餐分类
-- ============================================
CREATE TABLE `category` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '分类ID',
    `name` VARCHAR(32) NOT NULL COMMENT '分类名称',
    `type` TINYINT NOT NULL COMMENT '分类类型：1-菜品分类 2-套餐分类',
    `sort` INT NOT NULL DEFAULT 0 COMMENT '排序值',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '分类状态：1-启用 0-禁用',
    `branch_id` BIGINT NOT NULL COMMENT '分店ID',
    `is_deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '软删除标识：1-已删 0-未删',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
    `create_user` BIGINT NOT NULL DEFAULT 1 COMMENT '创建人ID',
    `update_user` BIGINT NOT NULL DEFAULT 1 COMMENT '最后修改人ID',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_cat_name_type_branch` (`name`, `type`, `branch_id`),
    KEY `idx_cat_type_status_branch` (`type`, `status`, `branch_id`),
    KEY `idx_cat_deleted` (`is_deleted`),
    CONSTRAINT `fk_cat_branch` FOREIGN KEY (`branch_id`) REFERENCES `branch` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='分类表';

-- ============================================
-- 7. 菜品表（dish）- 核心商品表
-- ============================================
CREATE TABLE `dish` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '菜品ID',
    `name` VARCHAR(32) NOT NULL COMMENT '菜品名称',
    `category_id` BIGINT NOT NULL COMMENT '分类ID',
    `price` DECIMAL(10,2) NOT NULL COMMENT '基础单价',
    `specifications` JSON DEFAULT NULL COMMENT '规格配置',
    `image` VARCHAR(255) DEFAULT NULL COMMENT '菜品图片地址（OSS）',
    `description` VARCHAR(255) DEFAULT NULL COMMENT '菜品描述',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '售卖状态：1-起售 0-停售',
    `branch_id` BIGINT NOT NULL COMMENT '分店ID',
    `is_deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '软删除标识：1-已删 0-未删',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
    `create_user` BIGINT NOT NULL DEFAULT 1 COMMENT '创建人ID',
    `update_user` BIGINT NOT NULL DEFAULT 1 COMMENT '最后修改人ID',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_dish_name_branch` (`name`, `branch_id`),
    KEY `idx_dish_cat_status_branch` (`category_id`, `status`, `branch_id`),
    KEY `idx_dish_deleted` (`is_deleted`),
    CONSTRAINT `fk_dish_category` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`) ON UPDATE CASCADE,
    CONSTRAINT `fk_dish_branch` FOREIGN KEY (`branch_id`) REFERENCES `branch` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='菜品表';

-- ============================================
-- 8. 菜品口味表（dish_flavor）- 菜品多口味配置
-- ============================================
CREATE TABLE `dish_flavor` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '口味ID',
    `dish_id` BIGINT NOT NULL COMMENT '菜品ID',
    `name` VARCHAR(32) NOT NULL COMMENT '口味名称',
    `value` VARCHAR(255) NOT NULL COMMENT '口味值',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
    PRIMARY KEY (`id`),
    KEY `idx_flavor_dish` (`dish_id`),
    CONSTRAINT `fk_flavor_dish` FOREIGN KEY (`dish_id`) REFERENCES `dish` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='菜品口味表';

-- ============================================
-- 9. 套餐表（setmeal）- 组合商品表
-- ============================================
CREATE TABLE `setmeal` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '套餐ID',
    `name` VARCHAR(32) NOT NULL COMMENT '套餐名称',
    `category_id` BIGINT NOT NULL COMMENT '分类ID',
    `price` DECIMAL(10,2) NOT NULL COMMENT '套餐总价',
    `image` VARCHAR(255) DEFAULT NULL COMMENT '套餐图片地址（OSS）',
    `description` VARCHAR(255) DEFAULT NULL COMMENT '套餐描述',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '售卖状态：1-起售 0-停售',
    `branch_id` BIGINT NOT NULL COMMENT '分店ID',
    `is_deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '软删除标识：1-已删 0-未删',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
    `create_user` BIGINT NOT NULL DEFAULT 1 COMMENT '创建人ID',
    `update_user` BIGINT NOT NULL DEFAULT 1 COMMENT '最后修改人ID',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_setmeal_name_branch` (`name`, `branch_id`),
    KEY `idx_setmeal_cat_status_branch` (`category_id`, `status`, `branch_id`),
    KEY `idx_setmeal_deleted` (`is_deleted`),
    CONSTRAINT `fk_setmeal_category` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`) ON UPDATE CASCADE,
    CONSTRAINT `fk_setmeal_branch` FOREIGN KEY (`branch_id`) REFERENCES `branch` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='套餐表';

-- ============================================
-- 10. 套餐菜品关系表（setmeal_dish）- 多对多关联
-- ============================================
CREATE TABLE `setmeal_dish` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '关联ID',
    `setmeal_id` BIGINT NOT NULL COMMENT '套餐ID',
    `dish_id` BIGINT NOT NULL COMMENT '菜品ID',
    `name` VARCHAR(32) NOT NULL COMMENT '菜品名称（冗余）',
    `price` DECIMAL(10,2) NOT NULL COMMENT '菜品单价（冗余）',
    `copies` INT NOT NULL COMMENT '菜品份数',
    `sort` INT NOT NULL DEFAULT 0 COMMENT '排序值',
    PRIMARY KEY (`id`),
    KEY `idx_sd_setmeal` (`setmeal_id`),
    KEY `idx_sd_dish` (`dish_id`),
    CONSTRAINT `fk_sd_setmeal` FOREIGN KEY (`setmeal_id`) REFERENCES `setmeal` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_sd_dish` FOREIGN KEY (`dish_id`) REFERENCES `dish` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='套餐菜品关系表';

-- ============================================
-- 11. 订单表（orders）- 核心业务表
-- ============================================
CREATE TABLE `orders` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '订单ID',
    `number` VARCHAR(50) NOT NULL COMMENT '订单号',
    `status` TINYINT NOT NULL COMMENT '订单状态：1-待付款 2-待接单 3-已接单 4-派送中 5-已完成 6-已取消',
    `branch_id` BIGINT NOT NULL COMMENT '分店ID',
    `consignee` VARCHAR(32) NOT NULL COMMENT '收货人',
    `phone` VARCHAR(11) NOT NULL COMMENT '收货人手机号',
    `address` VARCHAR(255) NOT NULL COMMENT '详细地址',
    `order_time` DATETIME NOT NULL COMMENT '下单时间',
    `checkout_time` DATETIME DEFAULT NULL COMMENT '付款时间',
    `pay_method` TINYINT DEFAULT NULL COMMENT '支付方式：1-微信支付 2-支付宝支付',
    `pay_status` TINYINT NOT NULL DEFAULT 0 COMMENT '支付状态：0-未支付 1-已支付 2-退款',
    `amount` DECIMAL(10,2) NOT NULL COMMENT '订单总金额',
    `pack_amount` DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT '打包费',
    `tableware_number` INT NOT NULL DEFAULT 0 COMMENT '餐具数量',
    `tableware_status` TINYINT NOT NULL DEFAULT 1 COMMENT '餐具状态：1-按餐量提供 0-自定义数量',
    `remark` VARCHAR(100) DEFAULT NULL COMMENT '订单备注',
    `cancel_reason` VARCHAR(255) DEFAULT NULL COMMENT '取消原因',
    `rejection_reason` VARCHAR(255) DEFAULT NULL COMMENT '拒单原因',
    `cancel_time` DATETIME DEFAULT NULL COMMENT '取消时间',
    `estimated_delivery_time` DATETIME DEFAULT NULL COMMENT '预计送达时间',
    `delivery_time` DATETIME DEFAULT NULL COMMENT '实际送达时间',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
    `update_user` BIGINT NOT NULL COMMENT '最后修改人ID',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_order_number` (`number`),
    KEY `idx_order_status_time_branch` (`status`, `order_time`, `branch_id`),
    KEY `idx_order_consignee_phone` (`consignee`, `phone`),
    KEY `idx_order_branch` (`branch_id`),
    CONSTRAINT `fk_order_branch` FOREIGN KEY (`branch_id`) REFERENCES `branch` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单表';

-- ============================================
-- 12. 订单明细表（order_detail）- 订单商品明细
-- ============================================
CREATE TABLE `order_detail` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '明细ID',
    `order_id` BIGINT NOT NULL COMMENT '订单ID',
    `name` VARCHAR(32) NOT NULL COMMENT '商品名称',
    `image` VARCHAR(255) DEFAULT NULL COMMENT '商品图片地址（冗余）',
    `dish_id` BIGINT DEFAULT NULL COMMENT '菜品ID',
    `setmeal_id` BIGINT DEFAULT NULL COMMENT '套餐ID',
    `dish_flavor` VARCHAR(50) DEFAULT NULL COMMENT '菜品口味',
    `number` INT NOT NULL COMMENT '商品数量',
    `amount` DECIMAL(10,2) NOT NULL COMMENT '商品单价',
    `total_amount` DECIMAL(10,2) NOT NULL COMMENT '商品总价',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_od_order_id` (`order_id`),
    KEY `idx_od_dish_id` (`dish_id`),
    KEY `idx_od_setmeal_id` (`setmeal_id`),
    CONSTRAINT `fk_od_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_od_dish` FOREIGN KEY (`dish_id`) REFERENCES `dish` (`id`) ON UPDATE CASCADE,
    CONSTRAINT `fk_od_setmeal` FOREIGN KEY (`setmeal_id`) REFERENCES `setmeal` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单明细表';

-- ============================================
-- 13. 操作日志表（operation_log）- 敏感操作审计
-- ============================================
CREATE TABLE `operation_log` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '日志ID',
    `operator_id` BIGINT NOT NULL COMMENT '操作人ID',
    `operator_name` VARCHAR(32) NOT NULL COMMENT '操作人姓名（冗余）',
    `branch_id` BIGINT NOT NULL COMMENT '操作分店ID',
    `module` VARCHAR(32) NOT NULL COMMENT '操作模块',
    `operation_type` VARCHAR(16) NOT NULL COMMENT '操作类型',
    `content` VARCHAR(255) NOT NULL COMMENT '操作内容',
    `ip` VARCHAR(32) NOT NULL COMMENT '操作IP地址',
    `operation_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '操作状态：1-成功 0-失败',
    `error_msg` VARCHAR(512) DEFAULT NULL COMMENT '错误信息',
    PRIMARY KEY (`id`),
    KEY `idx_oplog_operator_time` (`operator_id`, `operation_time`),
    KEY `idx_oplog_module_type` (`module`, `operation_type`),
    KEY `idx_oplog_branch` (`branch_id`),
    KEY `idx_oplog_time` (`operation_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='操作日志表';

-- ============================================
-- 14. 登录日志表（login_log）- 登录审计
-- ============================================
CREATE TABLE `login_log` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '日志ID',
    `employee_id` BIGINT NOT NULL DEFAULT 0 COMMENT '员工ID',
    `username` VARCHAR(32) NOT NULL COMMENT '登录用户名',
    `branch_id` BIGINT DEFAULT NULL COMMENT '所属分店ID',
    `ip` VARCHAR(32) NOT NULL COMMENT '登录IP地址',
    `login_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登录时间',
    `status` TINYINT NOT NULL COMMENT '登录状态：1-成功 0-失败',
    `error_msg` VARCHAR(255) DEFAULT NULL COMMENT '失败原因',
    `user_agent` VARCHAR(512) DEFAULT NULL COMMENT '浏览器/设备信息',
    PRIMARY KEY (`id`),
    KEY `idx_loginlog_emp_time` (`employee_id`, `login_time`),
    KEY `idx_loginlog_username_status` (`username`, `status`),
    KEY `idx_loginlog_time` (`login_time`),
    KEY `idx_loginlog_branch` (`branch_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='登录日志表';

-- ============================================
-- 15. 数据字典表（dict）- 统一状态管理
-- ============================================
CREATE TABLE `dict` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '字典ID',
    `dict_type` VARCHAR(32) NOT NULL COMMENT '字典类型',
    `dict_code` INT NOT NULL COMMENT '字典编码',
    `dict_label` VARCHAR(32) NOT NULL COMMENT '字典标签',
    `dict_desc` VARCHAR(128) DEFAULT NULL COMMENT '字典描述',
    `sort` INT NOT NULL DEFAULT 0 COMMENT '排序值',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '字典状态：1-启用 0-禁用',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_dict_type_code` (`dict_type`, `dict_code`),
    KEY `idx_dict_type` (`dict_type`),
    KEY `idx_dict_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='数据字典表';

-- ============================================
-- 外卖管理系统全表测试数据（按外键依赖顺序插入）
-- ============================================
-- 15张表完整清单（核对）：
-- 1. branch（分店表）
-- 2. role（角色表）
-- 3. permission（权限表）
-- 4. role_permission（角色权限关联表）
-- 5. employee（员工表）
-- 6. dict（数据字典表）
-- 7. category（分类表）
-- 8. dish（菜品表）
-- 9. dish_flavor（菜品口味表）
-- 10. setmeal（套餐表）
-- 11. setmeal_dish（套餐菜品关联表）
-- 12. `order`（订单表）
-- 13. order_detail（订单项表）
-- 14. operation_log（操作日志表）
-- 15. login_log（登录日志表）
-- ============================================
USE `deliver_management`;

-- 1. 分店表（branch）- 30条测试数据
INSERT INTO `branch` (`id`, `name`, `address`, `contact_name`, `contact_phone`, `status`, `is_deleted`, `create_user`, `update_user`) 
VALUES
(1, '总店', '系统默认地址', '系统管理员', '13800138000', 1, 0, 1, 1),
(2, '朝阳分店', '北京市朝阳区建国路88号', '李经理', '13800138001', 1, 0, 1, 1),
(3, '海淀分店', '北京市海淀区中关村大街1号', '王店长', '13800138002', 1, 0, 1, 1),
(4, '东城分店', '北京市东城区东单北大街8号', '张主管', '13800138003', 1, 0, 1, 1),
(5, '西城分店', '北京市西城区西长安街10号', '刘经理', '13800138004', 0, 0, 1, 1),
(6, '丰台分店', '北京市丰台区马家堡东路15号', '赵店长', '13800138005', 1, 0, 1, 1),
(7, '通州分店', '北京市通州区新华大街20号', '黄主管', '13800138006', 1, 0, 1, 1),
(8, '昌平分店', '北京市昌平区回龙观东大街30号', '周经理', '13800138007', 1, 0, 1, 1),
(9, '大兴分店', '北京市大兴区黄村西大街18号', '吴店长', '13800138008', 0, 0, 1, 1),
(10, '房山分店', '北京市房山区良乡中路12号', '郑主管', '13800138009', 1, 0, 1, 1),
(11, '门头沟分店', '北京市门头沟区永定镇路8号', '马经理', '13800138010', 1, 0, 1, 1),
(12, '顺义分店', '北京市顺义区天竺大街16号', '孙店长', '13800138011', 1, 0, 1, 1),
(13, '怀柔分店', '北京市怀柔区青春路22号', '朱主管', '13800138012', 0, 0, 1, 1),
(14, '密云分店', '北京市密云区鼓楼东大街15号', '胡经理', '13800138013', 1, 0, 1, 1),
(15, '延庆分店', '北京市延庆区妫水南街9号', '林店长', '13800138014', 1, 0, 1, 1),
(16, '上海浦东分店', '上海市浦东新区陆家嘴环路1000号', '郭主管', '13800138015', 1, 0, 1, 1),
(17, '上海浦西分店', '上海市黄浦区南京东路123号', '何经理', '13800138016', 1, 0, 1, 1),
(18, '广州天河分店', '广州市天河区天河路385号', '高店长', '13800138017', 1, 0, 1, 1),
(19, '广州越秀分店', '广州市越秀区北京路188号', '罗主管', '13800138018', 0, 0, 1, 1),
(20, '深圳南山分店', '深圳市南山区深南大道999号', '梁经理', '13800138019', 1, 0, 1, 1),
(21, '深圳福田分店', '深圳市福田区华强北路2000号', '宋店长', '13800138020', 1, 0, 1, 1),
(22, '成都武侯分店', '成都市武侯区武侯祠大街231号', '韩主管', '13800138021', 1, 0, 1, 1),
(23, '成都锦江分店', '成都市锦江区春熙路步行街88号', '唐经理', '13800138022', 1, 0, 1, 1),
(24, '杭州西湖分店', '杭州市西湖区西湖大道12号', '冯店长', '13800138023', 1, 0, 1, 1),
(25, '杭州余杭分店', '杭州市余杭区文一西路969号', '陈主管', '13800138024', 0, 0, 1, 1),
(26, '武汉江汉分店', '武汉市江汉区解放大道688号', '沈经理', '13800138025', 1, 0, 1, 1),
(27, '武汉武昌分店', '武汉市武昌区中南路14号', '杨店长', '13800138026', 1, 0, 1, 1),
(28, '重庆渝中分店', '重庆市渝中区解放碑步行街1号', '钟主管', '13800138027', 1, 0, 1, 1),
(29, '重庆江北分店', '重庆市江北区观音桥步行街8号', '姜经理', '13800138028', 1, 0, 1, 1),
(30, '西安雁塔分店', '西安市雁塔区雁塔路1号', '石店长', '13800138029', 0, 0, 1, 1);

-- 2. 角色表（role）- 6条测试数据
INSERT INTO `role` (`id`, `name`, `description`, `status`, `create_user`, `update_user`) VALUES
(1, '管理员', '系统最高权限，可操作所有模块', 1, 1, 1),
(2, '店长', '分店管理者，管理分店日常运营', 1, 1, 1),
(3, '收银员', '前台收银、订单核销', 1, 1, 1),
(4, '厨师', '后厨制作、菜品管理', 1, 1, 1),
(5, '配送员', '订单配送、状态更新', 1, 1, 1),
(6, '财务', '营收统计、账单管理', 0, 1, 1); -- 禁用角色示例

-- 3. 权限表（permission）- 60条测试数据（适配最新结构）
INSERT INTO `permission` (`id`, `name`, `type`, `path`, `parent_id`, `sort`, `status`) 
VALUES
-- 一级菜单：系统管理
(1, '系统管理', 1, '/system', NULL, 1, 1),
  -- 二级菜单：分店管理
  (2, '分店管理', 1, '/system/branch', 1, 2, 1),
    (3, '分店新增', 2, 'branch:add', 2, 1, 1),
    (4, '分店编辑', 2, 'branch:edit', 2, 2, 1),
    (5, '分店删除', 2, 'branch:delete', 2, 3, 0),
    (6, '分店查询', 2, 'branch:query', 2, 4, 1),
    (7, '分店导出', 2, 'branch:export', 2, 5, 1),
  -- 二级菜单：角色管理
  (8, '角色管理', 1, '/system/role', 1, 3, 1),
    (9, '角色新增', 2, 'role:add', 8, 1, 1),
    (10, '角色编辑', 2, 'role:edit', 8, 2, 1),
    (11, '角色删除', 2, 'role:delete', 8, 3, 1),
    (12, '角色查询', 2, 'role:query', 8, 4, 1),
    (13, '分配权限', 2, 'role:assign', 8, 5, 1),
  -- 二级菜单：员工管理
  (14, '员工管理', 1, '/system/employee', 1, 4, 1),
    (15, '员工新增', 2, 'employee:add', 14, 1, 1),
    (16, '员工编辑', 2, 'employee:edit', 14, 2, 1),
    (17, '员工删除', 2, 'employee:delete', 14, 3, 0),
    (18, '员工查询', 2, 'employee:query', 14, 4, 1),
    (19, '重置密码', 2, 'employee:resetPwd', 14, 5, 1),
  -- 二级菜单：数据字典
  (20, '数据字典', 1, '/system/dict', 1, 5, 1),
    (21, '字典新增', 2, 'dict:add', 20, 1, 1),
    (22, '字典编辑', 2, 'dict:edit', 20, 2, 1),
    (23, '字典删除', 2, 'dict:delete', 20, 3, 1),
    (24, '字典查询', 2, 'dict:query', 20, 4, 1),
  -- 二级菜单：日志管理
  (25, '日志管理', 1, '/system/log', 1, 6, 1),
    (26, '操作日志', 1, '/system/log/operation', 25, 1, 1),
      (27, '操作日志查询', 2, 'operationLog:query', 26, 1, 1),
      (28, '操作日志导出', 2, 'operationLog:export', 26, 2, 1),
    (29, '登录日志', 1, '/system/log/login', 25, 2, 1),
      (30, '登录日志查询', 2, 'loginLog:query', 29, 1, 1),
      (31, '登录日志清理', 2, 'loginLog:clean', 29, 2, 0),
-- 一级菜单：菜品管理
(32, '菜品管理', 1, '/dish', NULL, 2, 1),
  (33, '菜品分类', 1, '/dish/category', 32, 1, 1),
    (34, '分类新增', 2, 'category:add', 33, 1, 1),
    (35, '分类编辑', 2, 'category:edit', 33, 2, 1),
    (36, '分类删除', 2, 'category:delete', 33, 3, 1),
    (37, '分类查询', 2, 'category:query', 33, 4, 1),
  (38, '菜品列表', 1, '/dish/list', 32, 2, 1),
    (39, '菜品新增', 2, 'dish:add', 38, 1, 1),
    (40, '菜品编辑', 2, 'dish:edit', 38, 2, 1),
    (41, '菜品删除', 2, 'dish:delete', 38, 3, 1),
    (42, '菜品查询', 2, 'dish:query', 38, 4, 1),
    (43, '菜品上下架', 2, 'dish:status', 38, 5, 1),
-- 一级菜单：套餐管理
(44, '套餐管理', 1, '/setmeal', NULL, 3, 1),
  (45, '套餐新增', 2, 'setmeal:add', 44, 1, 1),
  (46, '套餐编辑', 2, 'setmeal:edit', 44, 2, 1),
  (47, '套餐删除', 2, 'setmeal:delete', 44, 3, 0),
  (48, '套餐查询', 2, 'setmeal:query', 44, 4, 1),
  (49, '套餐上下架', 2, 'setmeal:status', 44, 5, 1),
-- 一级菜单：订单管理
(50, '订单管理', 1, '/order', NULL, 4, 1),
  (51, '订单查询', 2, 'order:query', 50, 1, 1),
  (52, '订单接单', 2, 'order:accept', 50, 2, 1),
  (53, '订单拒单', 2, 'order:reject', 50, 3, 1),
  (54, '订单取消', 2, 'order:cancel', 50, 4, 1),
  (55, '订单完成', 2, 'order:complete', 50, 5, 1),
-- 一级菜单：统计分析
(56, '统计分析', 1, '/statistics', NULL, 5, 1),
(57, '营收统计', 2, 'statistics:revenue', 56, 1, 1),
(58, '订单统计', 2, 'statistics:order', 56, 2, 1),
(59, '菜品销量统计', 2, 'statistics:dish', 56, 3, 1),
(60, '套餐销量统计', 2, 'statistics:setmeal', 56, 4, 1);

-- 4. 角色权限关联表（role_permission）- 50条测试数据
INSERT INTO `role_permission` (`id`, `role_id`, `permission_id`) 
VALUES
-- 管理员（1）：全权限
(1, 1, 1), (2, 1, 2), (3, 1, 3), (4, 1, 4), (5, 1, 5),
(6, 1, 6), (7, 1, 7), (8, 1, 8), (9, 1, 9), (10, 1, 10),
(11, 1, 11), (12, 1, 12), (13, 1, 13), (14, 1, 14), (15, 1, 15),
(16, 1, 16), (17, 1, 17), (18, 1, 18), (19, 1, 19), (20, 1, 20),
(21, 1, 21), (22, 1, 22), (23, 1, 23), (24, 1, 24), (25, 1, 25),
(26, 1, 26), (27, 1, 27), (28, 1, 28), (29, 1, 29), (30, 1, 30),
(31, 1, 31), (32, 1, 32), (33, 1, 33), (34, 1, 34), (35, 1, 35),
(36, 1, 36), (37, 1, 37), (38, 1, 38), (39, 1, 39), (40, 1, 40),
(41, 1, 41), (42, 1, 42), (43, 1, 43), (44, 1, 44), (45, 1, 45),
(46, 1, 46), (47, 1, 47), (48, 1, 48), (49, 1, 49), (50, 1, 50),
-- 店长（2）：核心业务权限
(51, 2, 2), (52, 2, 6), (53, 2, 14), (54, 2, 18), (55, 2, 32),
(56, 2, 37), (57, 2, 38), (58, 2, 42), (59, 2, 44), (60, 2, 48),
(61, 2, 50), (62, 2, 51), (63, 2, 52), (64, 2, 53), (65, 2, 56),
-- 收银员（3）：订单相关权限
(66, 3, 50), (67, 3, 51), (68, 3, 52), (69, 3, 54), (70, 3, 55),
-- 厨师（4）：菜品/套餐权限
(71, 4, 32), (72, 4, 37), (73, 4, 38), (74, 4, 42), (75, 4, 43),
(76, 4, 44), (77, 4, 48), (78, 4, 49),
-- 配送员（5）：订单配送权限
(79, 5, 50), (80, 5, 51), (81, 5, 55);

-- 5. 员工表（employee）- 50条测试数据
INSERT INTO `employee` (`id`, `username`, `password`, `name`, `phone`, `sex`, `role_id`, `branch_id`, `status`, `is_deleted`, `create_user`, `update_user`) 
VALUES
(1, 'admin', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '系统管理员', '13800138000', '男', 1, 1, 1, 0, 1, 1),
(2, 'manager', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '张店长', '13900000001', '男', 2, 1, 1, 0, 1, 1),
(3, 'cashier', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '王收银', '13900000002', '女', 3, 1, 1, 0, 1, 1),
(4, 'chef', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '李大厨', '13900000003', '男', 4, 1, 1, 0, 1, 1),
(5, 'emp001', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '刘一', '13800000004', '男', 2, 2, 1, 0, 1, 1),
(6, 'emp002', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '陈二', '13800000005', '女', 2, 3, 1, 0, 1, 1),
(7, 'emp003', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '张三', '13800000006', '男', 3, 4, 0, 0, 1, 1),
(8, 'emp004', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '李四', '13800000007', '女', 3, 5, 1, 0, 1, 1),
(9, 'emp005', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '王五', '13800000008', '男', 4, 6, 1, 0, 1, 1),
(10, 'emp006', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '赵六', '13800000009', '女', 4, 7, 1, 0, 1, 1),
(11, 'emp007', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '孙七', '13800000010', '男', 2, 8, 0, 0, 1, 1),
(12, 'emp008', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '周八', '13800000011', '女', 3, 9, 1, 0, 1, 1),
(13, 'emp009', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '吴九', '13800000012', '男', 4, 10, 1, 0, 1, 1),
(14, 'emp010', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '郑十', '13800000013', '女', 2, 11, 1, 0, 1, 1),
(15, 'emp011', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '冯十一', '13800000014', '男', 3, 12, 0, 0, 1, 1),
(16, 'emp012', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '陈十二', '13800000015', '女', 4, 13, 1, 0, 1, 1),
(17, 'emp013', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '褚十三', '13800000016', '男', 2, 14, 1, 0, 1, 1),
(18, 'emp014', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '卫十四', '13800000017', '女', 3, 15, 1, 0, 1, 1),
(19, 'emp015', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '蒋十五', '13800000018', '男', 4, 16, 1, 0, 1, 1),
(20, 'emp016', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '沈十六', '13800000019', '女', 2, 17, 0, 0, 1, 1),
(21, 'emp017', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '韩十七', '13800000020', '男', 3, 18, 1, 0, 1, 1),
(22, 'emp018', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '杨十八', '13800000021', '女', 4, 19, 1, 0, 1, 1),
(23, 'emp019', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '朱十九', '13800000022', '男', 2, 20, 1, 0, 1, 1),
(24, 'emp020', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '秦二十', '13800000023', '女', 3, 21, 0, 0, 1, 1),
(25, 'emp021', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '尤二一', '13800000024', '男', 4, 22, 1, 0, 1, 1),
(26, 'emp022', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '许二二', '13800000025', '女', 2, 23, 1, 0, 1, 1),
(27, 'emp023', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '何二三', '13800000026', '男', 3, 24, 1, 0, 1, 1),
(28, 'emp024', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '吕二四', '13800000027', '女', 4, 25, 0, 0, 1, 1),
(29, 'emp025', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '施二五', '13800000028', '男', 2, 26, 1, 0, 1, 1),
(30, 'emp026', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '张二六', '13800000029', '女', 3, 27, 1, 0, 1, 1),
(31, 'emp027', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '孔二七', '13800000030', '男', 4, 28, 1, 0, 1, 1),
(32, 'emp028', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '曹二八', '13800000031', '女', 2, 29, 0, 0, 1, 1),
(33, 'emp029', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '严二九', '13800000032', '男', 3, 30, 1, 0, 1, 1),
(34, 'emp030', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '华三十', '13800000033', '女', 4, 1, 1, 0, 1, 1),
(35, 'emp031', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '金三一', '13800000034', '男', 2, 2, 1, 0, 1, 1),
(36, 'emp032', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '魏三二', '13800000035', '女', 3, 3, 0, 0, 1, 1),
(37, 'emp033', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '陶三三', '13800000036', '男', 4, 4, 1, 0, 1, 1),
(38, 'emp034', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '姜三四', '13800000037', '女', 2, 5, 1, 0, 1, 1),
(39, 'emp035', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '戚三五', '13800000038', '男', 3, 6, 1, 0, 1, 1),
(40, 'emp036', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '谢三六', '13800000039', '女', 4, 7, 0, 0, 1, 1),
(41, 'emp037', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '邹三七', '13800000040', '男', 2, 8, 1, 0, 1, 1),
(42, 'emp038', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '喻三八', '13800000041', '女', 3, 9, 1, 0, 1, 1),
(43, 'emp039', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '柏三九', '13800000042', '男', 4, 10, 1, 0, 1, 1),
(44, 'emp040', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '水四十', '13800000043', '女', 2, 11, 0, 0, 1, 1),
(45, 'emp041', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '窦四一', '13800000044', '男', 3, 12, 1, 0, 1, 1),
(46, 'emp042', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '章四二', '13800000045', '女', 4, 13, 1, 0, 1, 1),
(47, 'emp043', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '云四三', '13800000046', '男', 2, 14, 1, 0, 1, 1),
(48, 'emp044', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '苏四四', '13800000047', '女', 3, 15, 0, 0, 1, 1),
(49, 'emp045', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '潘四五', '13800000048', '男', 4, 16, 1, 0, 1, 1),
(50, 'emp046', '$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2', '葛四六', '13800000049', '女', 2, 17, 1, 0, 1, 1);

-- 6. 数据字典表（dict）- 30条测试数据
INSERT INTO `dict` (`id`, `dict_type`, `dict_code`, `dict_label`, `dict_desc`, `sort`, `status`) VALUES
-- 订单状态
(1, 'order_status', 1, '待付款', '订单状态：待付款', 1, 1),
(2, 'order_status', 2, '待接单', '订单状态：待接单', 2, 1),
(3, 'order_status', 3, '已接单', '订单状态：已接单', 3, 1),
(4, 'order_status', 4, '派送中', '订单状态：派送中', 4, 1),
(5, 'order_status', 5, '已完成', '订单状态：已完成', 5, 1),
(6, 'order_status', 6, '已取消', '订单状态：已取消', 6, 1),
-- 支付方式
(7, 'pay_method', 1, '微信支付', '支付方式：微信支付', 1, 1),
(8, 'pay_method', 2, '支付宝支付', '支付方式：支付宝支付', 2, 1),
(9, 'pay_method', 3, '现金支付', '支付方式：现金支付', 3, 1),
-- 支付状态
(10, 'pay_status', 0, '未支付', '支付状态：未支付', 1, 1),
(11, 'pay_status', 1, '已支付', '支付状态：已支付', 2, 1),
(12, 'pay_status', 2, '退款', '支付状态：退款', 3, 1),
(13, 'pay_status', 3, '退款中', '支付状态：退款中', 4, 1),
-- 菜品/套餐状态
(14, 'dish_status', 1, '起售', '菜品状态：起售', 1, 1),
(15, 'dish_status', 0, '停售', '菜品状态：停售', 2, 1),
-- 分类类型
(16, 'category_type', 1, '菜品分类', '分类类型：菜品分类', 1, 1),
(17, 'category_type', 2, '套餐分类', '分类类型：套餐分类', 2, 1),
-- 账号状态
(18, 'account_status', 1, '正常', '账号状态：正常', 1, 1),
(19, 'account_status', 0, '锁定', '账号状态：锁定', 2, 1),
(20, 'account_status', 2, '注销', '账号状态：注销', 3, 1),
-- 通用状态
(21, 'common_status', 1, '启用', '通用状态：启用', 1, 1),
(22, 'common_status', 0, '禁用', '通用状态：禁用', 2, 1),
-- 餐具状态
(23, 'tableware_status', 1, '按餐量提供', '餐具状态：按餐量提供', 1, 1),
(24, 'tableware_status', 0, '自定义数量', '餐具状态：自定义数量', 2, 1),
-- 取消原因类型
(25, 'cancel_reason', 1, '用户主动取消', '订单取消原因：用户主动取消', 1, 1),
(26, 'cancel_reason', 2, '商家拒单', '订单取消原因：商家拒单', 2, 1),
(27, 'cancel_reason', 3, '超时未支付', '订单取消原因：超时未支付', 3, 1),
(28, 'cancel_reason', 4, '配送异常', '订单取消原因：配送异常', 4, 1),
-- 配送方式
(29, 'delivery_type', 1, '门店自提', '配送方式：门店自提', 1, 1),
(30, 'delivery_type', 2, '骑手配送', '配送方式：骑手配送', 2, 1);

-- 7. 分类表（category）- 50条测试数据
INSERT INTO `category` (`id`, `name`, `type`, `sort`, `status`, `branch_id`, `is_deleted`, `create_user`, `update_user`) 
VALUES
(10, '湘菜', 1, 1, 1, 1, 0, 1, 1),
(11, '川菜', 1, 2, 1, 1, 0, 1, 1),
(12, '饮品', 1, 3, 1, 1, 0, 1, 1),
(13, '主食', 1, 4, 1, 1, 0, 1, 1),
(14, '超值套餐', 2, 1, 1, 1, 0, 1, 1),
(15, '粤菜', 1, 5, 1, 1, 0, 1, 1),
(16, '苏菜', 1, 6, 1, 1, 0, 1, 1),
(17, '浙菜', 1, 7, 1, 1, 0, 1, 1),
(18, '闽菜', 1, 8, 0, 1, 0, 1, 1),
(19, '鲁菜', 1, 9, 1, 1, 0, 1, 1),
(20, '徽菜', 1, 10, 1, 1, 0, 1, 1),
(21, '素菜', 1, 11, 1, 1, 0, 1, 1),
(22, '凉菜', 1, 12, 0, 1, 0, 1, 1),
(23, '汤品', 1, 13, 1, 1, 0, 1, 1),
(24, '小吃', 1, 14, 1, 1, 0, 1, 1),
(25, '儿童套餐', 2, 2, 1, 1, 0, 1, 1),
(26, '家庭套餐', 2, 3, 1, 1, 0, 1, 1),
(27, '商务套餐', 2, 4, 0, 1, 0, 1, 1),
(28, '夜宵套餐', 2, 5, 1, 1, 0, 1, 1),
(29, '早餐套餐', 2, 6, 1, 1, 0, 1, 1),
(30, '湘菜', 1, 1, 1, 2, 0, 1, 1),
(31, '川菜', 1, 2, 1, 2, 0, 1, 1),
(32, '饮品', 1, 3, 0, 2, 0, 1, 1),
(33, '主食', 1, 4, 1, 2, 0, 1, 1),
(34, '超值套餐', 2, 1, 1, 2, 0, 1, 1),
(35, '湘菜', 1, 1, 1, 3, 0, 1, 1),
(36, '川菜', 1, 2, 0, 3, 0, 1, 1),
(37, '饮品', 1, 3, 1, 3, 0, 1, 1),
(38, '主食', 1, 4, 1, 3, 0, 1, 1),
(39, '超值套餐', 2, 1, 1, 3, 0, 1, 1),
(40, '粤菜', 1, 5, 1, 4, 0, 1, 1),
(41, '苏菜', 1, 6, 0, 4, 0, 1, 1),
(42, '浙菜', 1, 7, 1, 4, 0, 1, 1),
(43, '闽菜', 1, 8, 1, 4, 0, 1, 1),
(44, '鲁菜', 1, 9, 0, 4, 0, 1, 1),
(45, '家庭套餐', 2, 2, 1, 4, 0, 1, 1),
(46, '商务套餐', 2, 3, 1, 5, 0, 1, 1),
(47, '夜宵套餐', 2, 4, 0, 5, 0, 1, 1),
(48, '早餐套餐', 2, 5, 1, 5, 0, 1, 1),
(49, '儿童套餐', 2, 6, 1, 5, 0, 1, 1),
(50, '素菜', 1, 10, 1, 6, 0, 1, 1);

-- 8. 菜品表（dish）- 50条测试数据
INSERT INTO `dish` (`id`, `name`, `category_id`, `price`, `specifications`, `image`, `description`, `status`, `branch_id`, `is_deleted`, `create_user`, `update_user`) 
VALUES
(100, '辣椒炒肉', 10, 28.00, '[{"name":"辣度","values":["微辣","中辣","特辣"]}]', 'https://example.com/dish1.jpg', '地道湘菜，鲜辣下饭', 1, 1, 0, 1, 1),
(101, '剁椒鱼头', 10, 68.00, '[]', 'https://example.com/dish2.jpg', '鲜嫩鱼头，秘制剁椒', 1, 1, 0, 1, 1),
(102, '宫保鸡丁', 11, 32.00, '[]', 'https://example.com/dish3.jpg', '经典川菜，酸甜微辣', 1, 1, 0, 1, 1),
(103, '可乐', 12, 3.00, '[]', 'https://example.com/drink1.jpg', '冰镇可乐', 1, 1, 0, 1, 1),
(104, '米饭', 13, 2.00, '[]', 'https://example.com/rice.jpg', '五常大米', 1, 1, 0, 1, 1),
(105, '白切鸡', 15, 58.00, '[]', 'https://example.com/dish4.jpg', '经典粤菜，皮滑肉嫩', 1, 1, 0, 1, 1),
(106, '松鼠桂鱼', 16, 88.00, '[]', 'https://example.com/dish5.jpg', '苏菜代表，酸甜酥脆', 1, 1, 0, 1, 1),
(107, '西湖醋鱼', 17, 48.00, '[]', 'https://example.com/dish6.jpg', '浙菜经典，酸甜适口', 1, 1, 0, 1, 1),
(108, '佛跳墙', 18, 198.00, '[]', 'https://example.com/dish7.jpg', '闽菜之首，滋补鲜美', 0, 1, 0, 1, 1),
(109, '葱烧海参', 19, 128.00, '[]', 'https://example.com/dish8.jpg', '鲁菜经典，咸鲜入味', 1, 1, 0, 1, 1),
(110, '臭鳜鱼', 20, 78.00, '[]', 'https://example.com/dish9.jpg', '徽菜代表，闻臭吃香', 1, 1, 0, 1, 1),
(111, '清炒时蔬', 21, 18.00, '[]', 'https://example.com/dish10.jpg', '时令素菜，清爽解腻', 1, 1, 0, 1, 1),
(112, '拍黄瓜', 22, 12.00, '[]', 'https://example.com/dish11.jpg', '经典凉菜，酸辣开胃', 0, 1, 0, 1, 1),
(113, '例汤', 23, 10.00, '[]', 'https://example.com/dish12.jpg', '每日例汤，暖心暖胃', 1, 1, 0, 1, 1),
(114, '小笼包', 24, 20.00, '[]', 'https://example.com/dish13.jpg', '江南小吃，皮薄馅足', 1, 1, 0, 1, 1),
(115, '麻婆豆腐', 11, 18.00, '[{"name":"辣度","values":["微辣","中辣","特辣"]}]', 'https://example.com/dish14.jpg', '川菜经典，麻辣鲜香', 1, 1, 0, 1, 1),
(116, '水煮鱼', 11, 58.00, '[{"name":"辣度","values":["微辣","中辣","特辣"]}]', 'https://example.com/dish15.jpg', '川菜经典，麻辣嫩滑', 1, 1, 0, 1, 1),
(117, '雪碧', 12, 3.00, '[]', 'https://example.com/drink2.jpg', '冰镇雪碧', 1, 1, 0, 1, 1),
(118, '芬达', 12, 3.00, '[]', 'https://example.com/drink3.jpg', '冰镇芬达', 1, 1, 0, 1, 1),
(119, '馒头', 13, 1.00, '[]', 'https://example.com/dish16.jpg', '手工馒头', 1, 1, 0, 1, 1),
(120, '面条', 13, 8.00, '[]', 'https://example.com/dish17.jpg', '手工面条', 1, 1, 0, 1, 1),
(121, '辣椒炒肉', 30, 28.00, '[{"name":"辣度","values":["微辣","中辣","特辣"]}]', 'https://example.com/dish1.jpg', '地道湘菜，鲜辣下饭', 1, 2, 0, 1, 1),
(122, '剁椒鱼头', 30, 68.00, '[]', 'https://example.com/dish2.jpg', '鲜嫩鱼头，秘制剁椒', 1, 2, 0, 1, 1),
(123, '宫保鸡丁', 31, 32.00, '[]', 'https://example.com/dish3.jpg', '经典川菜，酸甜微辣', 1, 2, 0, 1, 1),
(124, '可乐', 32, 3.00, '[]', 'https://example.com/drink1.jpg', '冰镇可乐', 0, 2, 0, 1, 1),
(125, '米饭', 33, 2.00, '[]', 'https://example.com/rice.jpg', '五常大米', 1, 2, 0, 1, 1),
(126, '辣椒炒肉', 35, 28.00, '[{"name":"辣度","values":["微辣","中辣","特辣"]}]', 'https://example.com/dish1.jpg', '地道湘菜，鲜辣下饭', 1, 3, 0, 1, 1),
(127, '宫保鸡丁', 36, 32.00, '[]', 'https://example.com/dish3.jpg', '经典川菜，酸甜微辣', 0, 3, 0, 1, 1),
(128, '可乐', 37, 3.00, '[]', 'https://example.com/drink1.jpg', '冰镇可乐', 1, 3, 0, 1, 1),
(129, '米饭', 38, 2.00, '[]', 'https://example.com/rice.jpg', '五常大米', 1, 3, 0, 1, 1),
(130, '白切鸡', 40, 58.00, '[]', 'https://example.com/dish4.jpg', '经典粤菜，皮滑肉嫩', 1, 4, 0, 1, 1),
(131, '松鼠桂鱼', 41, 88.00, '[]', 'https://example.com/dish5.jpg', '苏菜代表，酸甜酥脆', 0, 4, 0, 1, 1),
(132, '西湖醋鱼', 42, 48.00, '[]', 'https://example.com/dish6.jpg', '浙菜经典，酸甜适口', 1, 4, 0, 1, 1),
(133, '佛跳墙', 43, 198.00, '[]', 'https://example.com/dish7.jpg', '闽菜之首，滋补鲜美', 1, 4, 0, 1, 1),
(134, '葱烧海参', 44, 128.00, '[]', 'https://example.com/dish8.jpg', '鲁菜经典，咸鲜入味', 0, 4, 0, 1, 1),
(135, '回锅肉', 10, 32.00, '[{"name":"辣度","values":["微辣","中辣","特辣"]}]', 'https://example.com/dish18.jpg', '川菜经典，肥而不腻', 1, 1, 0, 1, 1),
(136, '鱼香肉丝', 11, 28.00, '[{"name":"辣度","values":["微辣","中辣","特辣"]}]', 'https://example.com/dish19.jpg', '川菜经典，酸甜辣香', 1, 1, 0, 1, 1),
(137, '酸菜鱼', 11, 68.00, '[{"name":"辣度","values":["微辣","中辣","特辣"]}]', 'https://example.com/dish20.jpg', '川菜经典，酸辣开胃', 1, 1, 0, 1, 1),
(138, '王老吉', 12, 5.00, '[]', 'https://example.com/drink4.jpg', '清热降火', 1, 1, 0, 1, 1),
(139, '加多宝', 12, 5.00, '[]', 'https://example.com/drink5.jpg', '清热降火', 1, 1, 0, 1, 1),
(140, '蛋炒饭', 13, 12.00, '[]', 'https://example.com/dish21.jpg', '经典炒饭，粒粒分明', 1, 1, 0, 1, 1),
(141, '扬州炒饭', 13, 18.00, '[]', 'https://example.com/dish22.jpg', '经典炒饭，配料丰富', 1, 1, 0, 1, 1),
(142, '炒米粉', 13, 15.00, '[]', 'https://example.com/dish23.jpg', '粤式炒粉，鲜香入味', 1, 1, 0, 1, 1),
(143, '酸辣土豆丝', 21, 16.00, '[{"name":"辣度","values":["微辣","中辣","特辣"]}]', 'https://example.com/dish24.jpg', '经典素菜，酸辣开胃', 1, 1, 0, 1, 1),
(144, '手撕包菜', 21, 18.00, '[{"name":"辣度","values":["微辣","中辣","特辣"]}]', 'https://example.com/dish25.jpg', '经典素菜，咸辣鲜香', 1, 1, 0, 1, 1),
(145, '凉拌海带丝', 22, 10.00, '[]', 'https://example.com/dish26.jpg', '经典凉菜，清爽解腻', 0, 1, 0, 1, 1),
(146, '皮蛋瘦肉粥', 24, 15.00, '[]', 'https://example.com/dish27.jpg', '经典粥品，营养美味', 1, 1, 0, 1, 1),
(147, '叉烧包', 24, 18.00, '[]', 'https://example.com/dish28.jpg', '粤式点心，甜咸适口', 1, 1, 0, 1, 1),
(148, '流沙包', 24, 20.00, '[]', 'https://example.com/dish29.jpg', '粤式点心，流心香甜', 1, 1, 0, 1, 1),
(149, '奶黄包', 24, 18.00, '[]', 'https://example.com/dish30.jpg', '粤式点心，奶香浓郁', 1, 1, 0, 1, 1),
(150, '豆沙包', 24, 15.00, '[]', 'https://example.com/dish31.jpg', '经典点心，香甜软糯', 1, 1, 0, 1, 1);

-- 9. 菜品口味表（dish_flavor）- 30条测试数据
INSERT INTO `dish_flavor` (`id`, `dish_id`, `name`, `value`) VALUES
(1, 100, '辣度', '["微辣","中辣","特辣"]'),
(2, 115, '辣度', '["微辣","中辣","特辣"]'),
(3, 116, '辣度', '["微辣","中辣","特辣"]'),
(4, 135, '辣度', '["微辣","中辣","特辣"]'),
(5, 136, '辣度', '["微辣","中辣","特辣"]'),
(6, 137, '辣度', '["微辣","中辣","特辣"]'),
(7, 143, '辣度', '["微辣","中辣","特辣"]'),
(8, 144, '辣度', '["微辣","中辣","特辣"]'),
(9, 121, '辣度', '["微辣","中辣","特辣"]'),
(10, 100, '口味', '["原味","酱香","香辣"]'),
(11, 115, '口味', '["原味","酱香","香辣"]'),
(12, 116, '口味', '["原味","藤椒","麻辣"]'),
(13, 135, '口味', '["原味","酱香","香辣"]'),
(14, 136, '口味', '["原味","泡椒","酸辣"]'),
(15, 137, '口味', '["原味","藤椒","麻辣"]'),
(16, 143, '口味', '["原味","酸辣","麻辣"]'),
(17, 144, '口味', '["原味","酸辣","麻辣"]'),
(18, 121, '口味', '["原味","酱香","香辣"]'),
(19, 101, '口味', '["原味","剁椒","蒜蓉"]'),
(20, 102, '口味', '["原味","微甜","特甜"]'),
(21, 105, '口味', '["原味","姜葱","沙姜"]'),
(22, 106, '口味', '["原味","酸甜","特甜"]'),
(23, 107, '口味', '["原味","酸甜","特甜"]'),
(24, 109, '口味', '["原味","咸鲜","酱香"]'),
(25, 110, '口味', '["原味","微辣","特辣"]'),
(26, 111, '口味', '["原味","蒜蓉","清炒"]'),
(27, 112, '口味', '["原味","麻辣","酸辣"]'),
(28, 113, '口味', '["原味","咸鲜","清淡"]'),
(29, 114, '口味', '["原味","鲜肉","虾仁"]'),
(30, 140, '口味', '["原味","酱油","番茄"]');

-- 10. 套餐表（setmeal）- 40条测试数据
INSERT INTO `setmeal` (`id`, `name`, `category_id`, `price`, `image`, `description`, `status`, `branch_id`, `is_deleted`, `create_user`, `update_user`) 
VALUES
(200, '单人满足餐', 14, 30.00, 'https://example.com/set1.jpg', '一荤一素一饮品', 1, 1, 0, 1, 1),
(201, '双人乐享餐', 14, 68.00, 'https://example.com/set2.jpg', '两荤一素两饮品', 1, 1, 0, 1, 1),
(202, '三人欢聚餐', 14, 98.00, 'https://example.com/set3.jpg', '三荤两素三饮品', 1, 1, 0, 1, 1),
(203, '儿童趣味餐', 25, 28.00, 'https://example.com/set4.jpg', '适合儿童，营养均衡', 1, 1, 0, 1, 1),
(204, '家庭幸福餐', 26, 168.00, 'https://example.com/set5.jpg', '四荤三素四饮品', 1, 1, 0, 1, 1),
(205, '商务精英餐', 27, 88.00, 'https://example.com/set6.jpg', '精致单人餐，高效便捷', 0, 1, 0, 1, 1),
(206, '夜宵嗨吃餐', 28, 128.00, 'https://example.com/set7.jpg', '烧烤+啤酒，夜宵必备', 1, 1, 0, 1, 1),
(207, '早餐元气餐', 29, 18.00, 'https://example.com/set8.jpg', '包子+粥+鸡蛋，元气满满', 1, 1, 0, 1, 1),
(208, '湘菜经典餐', 10, 58.00, 'https://example.com/set9.jpg', '经典湘菜组合', 1, 1, 0, 1, 1),
(209, '川菜双人餐', 14, 76.00, 'https://example.com/set10.jpg', '麻婆豆腐+水煮鱼', 1, 1, 0, 1, 1),
(210, '特色双人餐', 14, 146.00, 'https://example.com/set11.jpg', '白切鸡+松鼠桂鱼', 1, 1, 0, 1, 1),
(211, '西湖单人餐', 14, 66.00, 'https://example.com/set12.jpg', '西湖醋鱼+时蔬', 1, 1, 0, 1, 1),
(212, '海参滋补餐', 14, 146.00, 'https://example.com/set13.jpg', '葱烧海参+时蔬', 1, 1, 0, 1, 1),
(213, '徽菜尝鲜餐', 14, 96.00, 'https://example.com/set14.jpg', '臭鳜鱼+时蔬', 1, 1, 0, 1, 1);


-- ============================================
-- 补充5个表的测试数据（总计15表完整）
-- ============================================
USE `deliver_management`;

-- 11. 套餐菜品关联表（setmeal_dish）- 50条测试数据（关联套餐&菜品）
INSERT INTO `setmeal_dish` (`id`, `setmeal_id`, `dish_id`, `name`, `price`, `copies`, `sort`) 
VALUES
-- 单人满足餐（200）
(1, 200, 100, '辣椒炒肉', 28.00, 1, 1),
(2, 200, 111, '清炒时蔬', 18.00, 1, 2),
(3, 200, 103, '可乐', 3.00, 1, 3),
-- 双人乐享餐（201）
(4, 201, 100, '辣椒炒肉', 28.00, 1, 1),
(5, 201, 115, '麻婆豆腐', 18.00, 1, 2),
(6, 201, 111, '清炒时蔬', 18.00, 1, 3),
(7, 201, 103, '可乐', 3.00, 2, 4),
-- 三人欢聚餐（202）
(8, 202, 100, '辣椒炒肉', 28.00, 1, 1),
(9, 202, 115, '麻婆豆腐', 18.00, 1, 2),
(10, 202, 101, '剁椒鱼头', 68.00, 1, 3),
(11, 202, 111, '清炒时蔬', 18.00, 1, 4),
(12, 202, 113, '例汤', 10.00, 3, 5),
(13, 202, 103, '可乐', 3.00, 3, 6),
-- 儿童趣味餐（203）
(14, 203, 114, '小笼包', 20.00, 1, 1),
(15, 203, 103, '可乐', 3.00, 1, 2),
(16, 203, 111, '清炒时蔬', 18.00, 1, 3),
-- 家庭幸福餐（204）
(17, 204, 100, '辣椒炒肉', 28.00, 1, 1),
(18, 204, 101, '剁椒鱼头', 68.00, 1, 2),
(19, 204, 115, '麻婆豆腐', 18.00, 1, 3),
(20, 204, 116, '水煮鱼', 58.00, 1, 4),
(21, 204, 111, '清炒时蔬', 18.00, 2, 5),
(22, 204, 113, '例汤', 10.00, 4, 6),
(23, 204, 103, '可乐', 3.00, 4, 7),
-- 商务精英餐（205）
(24, 205, 105, '白切鸡', 58.00, 1, 1),
(25, 205, 111, '清炒时蔬', 18.00, 1, 2),
(26, 205, 113, '例汤', 10.00, 1, 3),
(27, 205, 103, '可乐', 3.00, 1, 4),
-- 夜宵嗨吃餐（206）
(28, 206, 114, '小笼包', 20.00, 2, 1),
(29, 206, 146, '皮蛋瘦肉粥', 15.00, 2, 2),
(30, 206, 103, '可乐', 3.00, 4, 3),
-- 早餐元气餐（207）
(31, 207, 114, '小笼包', 20.00, 1, 1),
(32, 207, 146, '皮蛋瘦肉粥', 15.00, 1, 2),
(33, 207, 104, '米饭', 2.00, 1, 3),
-- 其他套餐关联
(34, 208, 100, '辣椒炒肉', 28.00, 1, 1),
(35, 208, 101, '剁椒鱼头', 68.00, 1, 2),
(36, 208, 113, '例汤', 10.00, 1, 3),
(37, 209, 115, '麻婆豆腐', 18.00, 1, 1),
(38, 209, 116, '水煮鱼', 58.00, 1, 2),
(39, 209, 103, '可乐', 3.00, 1, 3),
(40, 210, 105, '白切鸡', 58.00, 1, 1),
(41, 210, 106, '松鼠桂鱼', 88.00, 1, 2),
(42, 210, 113, '例汤', 10.00, 1, 3),
(43, 211, 107, '西湖醋鱼', 48.00, 1, 1),
(44, 211, 111, '清炒时蔬', 18.00, 1, 2),
(45, 211, 103, '可乐', 3.00, 1, 3),
(46, 212, 109, '葱烧海参', 128.00, 1, 1),
(47, 212, 111, '清炒时蔬', 18.00, 1, 2),
(48, 212, 113, '例汤', 10.00, 1, 3),
(49, 213, 110, '臭鳜鱼', 78.00, 1, 1),
(50, 213, 111, '清炒时蔬', 18.00, 1, 2);

-- 12. 订单表（`order`）- 50条测试数据（注意order为关键字，需反引号）
INSERT INTO `orders` (`id`, `number`, `consignee`, `phone`, `address`, `amount`, `pay_method`, `pay_status`, `status`, `tableware_number`, `cancel_reason`, `branch_id`, `order_time`, `update_time`, `update_user`)
VALUES
-- 待付款/待接单/已接单/派送中/已完成/已取消 全状态覆盖
(1, 'ORD2025121400001', '张三', '13900000001', '北京市朝阳区建国路88号1单元101', 30.00, 1, 0, 1, 2, NULL, 1, '2025-12-14 08:00:00', '2025-12-14 08:00:00', 1),
(2, 'ORD2025121400002', '李四', '13900000002', '北京市海淀区中关村大街1号2单元202', 68.00, 2, 1, 2, 4, NULL, 1, '2025-12-14 08:10:00', '2025-12-14 08:10:00', 1),
(3, 'ORD2025121400003', '王五', '13900000003', '北京市东城区东单北大街8号3单元303', 98.00, 3, 1, 3, 6, NULL, 1, '2025-12-14 08:20:00', '2025-12-14 08:20:00', 1),
(4, 'ORD2025121400004', '赵六', '13900000004', '北京市西城区西长安街10号4单元404', 28.00, 1, 1, 4, 2, NULL, 1, '2025-12-14 08:30:00', '2025-12-14 08:30:00', 1),
(5, 'ORD2025121400005', '孙七', '13900000005', '北京市丰台区马家堡东路15号5单元505', 168.00, 2, 1, 5, 8, NULL, 1, '2025-12-14 08:40:00', '2025-12-14 08:40:00', 1),
(6, 'ORD2025121400006', '周八', '13900000006', '北京市通州区新华大街20号6单元606', 88.00, 3, 1, 6, 2, '用户主动取消', 1, '2025-12-14 08:50:00', '2025-12-14 08:55:00', 1),
(7, 'ORD2025121400007', '吴九', '13900000007', '北京市昌平区回龙观东大街30号7单元707', 128.00, 1, 0, 1, 4, NULL, 1, '2025-12-14 09:00:00', '2025-12-14 09:00:00', 1),
(8, 'ORD2025121400008', '郑十', '13900000008', '北京市大兴区黄村西大街18号8单元808', 18.00, 2, 1, 2, 1, NULL, 1, '2025-12-14 09:10:00', '2025-12-14 09:10:00', 1),
(9, 'ORD2025121400009', '冯十一', '13900000009', '北京市房山区良乡中路12号9单元909', 30.00, 3, 1, 3, 2, NULL, 2, '2025-12-14 09:20:00', '2025-12-14 09:20:00', 1),
(10, 'ORD2025121400010', '陈十二', '13900000010', '北京市门头沟区永定镇路8号10单元1010', 68.00, 1, 1, 4, 4, NULL, 2, '2025-12-14 09:30:00', '2025-12-14 09:30:00', 1),
(11, 'ORD2025121400011', '褚十三', '13900000011', '北京市顺义区天竺大街16号11单元1111', 98.00, 2, 1, 5, 6, NULL, 2, '2025-12-14 09:40:00', '2025-12-14 09:40:00', 1),
(12, 'ORD2025121400012', '卫十四', '13900000012', '北京市怀柔区青春路22号12单元1212', 28.00, 3, 1, 6, 2, '商家拒单', 2, '2025-12-14 09:50:00', '2025-12-14 09:55:00', 1),
(13, 'ORD2025121400013', '蒋十五', '13900000013', '北京市密云区鼓楼东大街15号13单元1313', 168.00, 1, 0, 1, 8, NULL, 3, '2025-12-14 10:00:00', '2025-12-14 10:00:00', 1),
(14, 'ORD2025121400014', '沈十六', '13900000014', '北京市延庆区妫水南街9号14单元1414', 88.00, 2, 1, 2, 2, NULL, 3, '2025-12-14 10:10:00', '2025-12-14 10:10:00', 1),
(15, 'ORD2025121400015', '韩十七', '13900000015', '上海市浦东新区陆家嘴环路1000号15单元1515', 128.00, 3, 1, 3, 4, NULL, 16, '2025-12-14 10:20:00', '2025-12-14 10:20:00', 1),
(16, 'ORD2025121400016', '杨十八', '13900000016', '上海市黄浦区南京东路123号16单元1616', 18.00, 1, 1, 4, 1, NULL, 17, '2025-12-14 10:30:00', '2025-12-14 10:30:00', 1),
(17, 'ORD2025121400017', '朱十九', '13900000017', '广州市天河区天河路385号17单元1717', 30.00, 2, 1, 5, 2, NULL, 18, '2025-12-14 10:40:00', '2025-12-14 10:40:00', 1),
(18, 'ORD2025121400018', '秦二十', '13900000018', '广州市越秀区北京路188号18单元1818', 68.00, 3, 1, 6, 4, '超时未支付', 19, '2025-12-14 10:50:00', '2025-12-14 11:00:00', 1),
(19, 'ORD2025121400019', '尤二一', '13900000019', '深圳市南山区深南大道999号19单元1919', 98.00, 1, 0, 1, 6, NULL, 20, '2025-12-14 11:00:00', '2025-12-14 11:00:00', 1),
(20, 'ORD2025121400020', '许二二', '13900000020', '深圳市福田区华强北路2000号20单元2020', 28.00, 2, 1, 2, 2, NULL, 21, '2025-12-14 11:10:00', '2025-12-14 11:10:00', 1),
-- 批量补充剩余30条（覆盖更多分店/状态）
(21, 'ORD2025121400021', '何二三', '13900000021', '成都市武侯区武侯祠大街231号21单元2121', 168.00, 3, 1, 3, 8, NULL, 22, '2025-12-14 11:20:00', '2025-12-14 11:20:00', 1),
(22, 'ORD2025121400022', '吕二四', '13900000022', '成都市锦江区春熙路步行街88号22单元2222', 88.00, 1, 1, 4, 2, NULL, 23, '2025-12-14 11:30:00', '2025-12-14 11:30:00', 1),
(23, 'ORD2025121400023', '施二五', '13900000023', '杭州市西湖区西湖大道12号23单元2323', 128.00, 2, 1, 5, 4, NULL, 24, '2025-12-14 11:40:00', '2025-12-14 11:40:00', 1),
(24, 'ORD2025121400024', '张二六', '13900000024', '杭州市余杭区文一西路969号24单元2424', 18.00, 3, 1, 6, 1, '配送异常', 25, '2025-12-14 11:50:00', '2025-12-14 12:00:00', 1),
(25, 'ORD2025121400025', '孔二七', '13900000025', '武汉市江汉区解放大道688号25单元2525', 30.00, 1, 0, 1, 2, NULL, 26, '2025-12-14 12:00:00', '2025-12-14 12:00:00', 1),
(26, 'ORD2025121400026', '曹二八', '13900000026', '武汉市武昌区中南路14号26单元2626', 68.00, 2, 1, 2, 4, NULL, 27, '2025-12-14 12:10:00', '2025-12-14 12:10:00', 1),
(27, 'ORD2025121400027', '严二九', '13900000027', '重庆市渝中区解放碑步行街1号27单元2727', 98.00, 3, 1, 3, 6, NULL, 28, '2025-12-14 12:20:00', '2025-12-14 12:20:00', 1),
(28, 'ORD2025121400028', '华三十', '13900000028', '重庆市江北区观音桥步行街8号28单元2828', 28.00, 1, 1, 4, 2, NULL, 29, '2025-12-14 12:30:00', '2025-12-14 12:30:00', 1),
(29, 'ORD2025121400029', '金三一', '13900000029', '西安市雁塔区雁塔路1号29单元2929', 168.00, 2, 1, 5, 8, NULL, 30, '2025-12-14 12:40:00', '2025-12-14 12:40:00', 1),
(30, 'ORD2025121400030', '魏三二', '13900000030', '北京市朝阳区建国路89号30单元3030', 88.00, 3, 1, 6, 2, '用户主动取消', 1, '2025-12-14 12:50:00', '2025-12-14 13:00:00', 1),
(31, 'ORD2025121400031', '陶三三', '13900000031', '北京市海淀区中关村大街2号31单元3131', 128.00, 1, 0, 1, 4, NULL, 1, '2025-12-14 13:00:00', '2025-12-14 13:00:00', 1),
(32, 'ORD2025121400032', '姜三四', '13900000032', '北京市东城区东单北大街9号32单元3232', 18.00, 2, 1, 2, 1, NULL, 1, '2025-12-14 13:10:00', '2025-12-14 13:10:00', 1),
(33, 'ORD2025121400033', '戚三五', '13900000033', '北京市西城区西长安街11号33单元3333', 30.00, 3, 1, 3, 2, NULL, 1, '2025-12-14 13:20:00', '2025-12-14 13:20:00', 1),
(34, 'ORD2025121400034', '谢三六', '13900000034', '北京市丰台区马家堡东路16号34单元3434', 68.00, 1, 1, 4, 4, NULL, 2, '2025-12-14 13:30:00', '2025-12-14 13:30:00', 1),
(35, 'ORD2025121400035', '邹三七', '13900000035', '北京市通州区新华大街21号35单元3535', 98.00, 2, 1, 5, 6, NULL, 2, '2025-12-14 13:40:00', '2025-12-14 13:40:00', 1),
(36, 'ORD2025121400036', '喻三八', '13900000036', '北京市昌平区回龙观东大街31号36单元3636', 28.00, 3, 1, 6, 2, '商家拒单', 2, '2025-12-14 13:50:00', '2025-12-14 14:00:00', 1),
(37, 'ORD2025121400037', '柏三九', '13900000037', '北京市大兴区黄村西大街19号37单元3737', 168.00, 1, 0, 1, 8, NULL, 3, '2025-12-14 14:00:00', '2025-12-14 14:00:00', 1),
(38, 'ORD2025121400038', '水四十', '13900000038', '北京市房山区良乡中路13号38单元3838', 88.00, 2, 1, 2, 2, NULL, 3, '2025-12-14 14:10:00', '2025-12-14 14:10:00', 1),
(39, 'ORD2025121400039', '窦四一', '13900000039', '北京市门头沟区永定镇路9号39单元3939', 128.00, 3, 1, 3, 4, NULL, 16, '2025-12-14 14:20:00', '2025-12-14 14:20:00', 1),
(40, 'ORD2025121400040', '章四二', '13900000040', '北京市顺义区天竺大街17号40单元4040', 18.00, 1, 1, 4, 1, NULL, 17, '2025-12-14 14:30:00', '2025-12-14 14:30:00', 1),
(41, 'ORD2025121400041', '云四三', '13900000041', '北京市怀柔区青春路23号41单元4141', 30.00, 2, 1, 5, 2, NULL, 18, '2025-12-14 14:40:00', '2025-12-14 14:40:00', 1),
(42, 'ORD2025121400042', '苏四四', '13900000042', '北京市密云区鼓楼东大街16号42单元4242', 68.00, 3, 1, 6, 4, '超时未支付', 19, '2025-12-14 14:50:00', '2025-12-14 15:00:00', 1),
(43, 'ORD2025121400043', '潘四五', '13900000043', '北京市延庆区妫水南街10号43单元4343', 98.00, 1, 0, 1, 6, NULL, 20, '2025-12-14 15:00:00', '2025-12-14 15:00:00', 1),
(44, 'ORD2025121400044', '葛四六', '13900000044', '上海市浦东新区陆家嘴环路1001号44单元4444', 28.00, 2, 1, 2, 2, NULL, 21, '2025-12-14 15:10:00', '2025-12-14 15:10:00', 1),
(45, 'ORD2025121400045', '董四七', '13900000045', '上海市黄浦区南京东路124号45单元4545', 168.00, 3, 1, 3, 8, NULL, 22, '2025-12-14 15:20:00', '2025-12-14 15:20:00', 1),
(46, 'ORD2025121400046', '梁四八', '13900000046', '成都市武侯区武侯祠大街232号46单元4646', 88.00, 1, 1, 4, 2, NULL, 23, '2025-12-14 15:30:00', '2025-12-14 15:30:00', 1),
(47, 'ORD2025121400047', '杜四九', '13900000047', '成都市锦江区春熙路步行街89号47单元4747', 128.00, 2, 1, 5, 4, NULL, 24, '2025-12-14 15:40:00', '2025-12-14 15:40:00', 1),
(48, 'ORD2025121400048', '阮五十', '13900000048', '杭州市西湖区西湖大道13号48单元4848', 18.00, 3, 1, 6, 1, '配送异常', 25, '2025-12-14 15:50:00', '2025-12-14 16:00:00', 1),
(49, 'ORD2025121400049', '席五一', '13900000049', '杭州市余杭区文一西路970号49单元4949', 30.00, 1, 0, 1, 2, NULL, 26, '2025-12-14 16:00:00', '2025-12-14 16:00:00', 1),
(50, 'ORD2025121400050', '季五二', '13900000050', '武汉市江汉区解放大道689号50单元5050', 68.00, 2, 1, 2, 4, NULL, 27, '2025-12-14 16:10:00', '2025-12-14 16:10:00', 1);

-- 13. 订单项表（order_detail）- 60条测试数据（关联订单&菜品/套餐）
INSERT INTO `order_detail` (`id`, `order_id`, `dish_id`, `setmeal_id`, `name`, `amount`, `number`, `dish_flavor`, `total_amount`) 
VALUES
-- 订单1（ORD2025121400001）- 单人满足餐（套餐）
(1, 1, NULL, 200, '单人满足餐', 30.00, 1, NULL, 30.00),
-- 订单2（ORD2025121400002）- 双人乐享餐（套餐）
(2, 2, NULL, 201, '双人乐享餐', 68.00, 1, NULL, 68.00),
-- 订单3（ORD2025121400003）- 三人欢聚餐（套餐）
(3, 3, NULL, 202, '三人欢聚餐', 98.00, 1, NULL, 98.00),
-- 订单4（ORD2025121400004）- 儿童趣味餐（套餐）
(4, 4, NULL, 203, '儿童趣味餐', 28.00, 1, NULL, 28.00),
-- 订单5（ORD2025121400005）- 家庭幸福餐（套餐）
(5, 5, NULL, 204, '家庭幸福餐', 168.00, 1, NULL, 168.00),
-- 订单6（ORD2025121400006）- 商务精英餐（套餐）+ 可乐
(6, 6, NULL, 205, '商务精英餐', 88.00, 1, NULL, 88.00),
(7, 6, 103, NULL, '可乐', 3.00, 1, NULL, 3.00),
-- 订单7（ORD2025121400007）- 夜宵嗨吃餐（套餐）
(8, 7, NULL, 206, '夜宵嗨吃餐', 128.00, 1, NULL, 128.00),
-- 订单8（ORD2025121400008）- 早餐元气餐（套餐）
(9, 8, NULL, 207, '早餐元气餐', 18.00, 1, NULL, 18.00),
-- 订单9（ORD2025121400009）- 单点菜品：辣椒炒肉+清炒时蔬+可乐
(10, 9, 100, NULL, '辣椒炒肉', 28.00, 1, '{"辣度":"微辣"}', 28.00),
(11, 9, 111, NULL, '清炒时蔬', 18.00, 1, NULL, 18.00),
(12, 9, 103, NULL, '可乐', 3.00, 1, NULL, 3.00),
-- 订单10（ORD2025121400010）- 单点菜品：麻婆豆腐+水煮鱼+雪碧
(13, 10, 115, NULL, '麻婆豆腐', 18.00, 1, '{"辣度":"中辣"}', 18.00),
(14, 10, 116, NULL, '水煮鱼', 58.00, 1, '{"辣度":"特辣"}', 58.00),
(15, 10, 117, NULL, '雪碧', 3.00, 1, NULL, 3.00),
-- 批量补充剩余45条（覆盖更多订单/菜品/口味）
(16, 11, 105, NULL, '白切鸡', 58.00, 1, '{"口味":"姜葱"}', 58.00),
(17, 11, 111, NULL, '清炒时蔬', 18.00, 1, NULL, 18.00),
(18, 11, 103, NULL, '可乐', 3.00, 1, NULL, 3.00),
(19, 12, 110, NULL, '臭鳜鱼', 78.00, 1, '{"辣度":"微辣"}', 78.00),
(20, 12, 113, NULL, '例汤', 10.00, 1, NULL, 10.00),
(21, 13, NULL, 200, '单人满足餐', 30.00, 2, NULL, 60.00),
(22, 13, 103, NULL, '可乐', 3.00, 2, NULL, 6.00),
(23, 14, NULL, 201, '双人乐享餐', 68.00, 1, NULL, 68.00),
(24, 14, 117, NULL, '雪碧', 3.00, 2, NULL, 6.00),
(25, 15, NULL, 202, '三人欢聚餐', 98.00, 1, NULL, 98.00),
(26, 15, 118, NULL, '芬达', 3.00, 3, NULL, 9.00),
(27, 16, NULL, 203, '儿童趣味餐', 28.00, 1, NULL, 28.00),
(28, 16, 104, NULL, '米饭', 2.00, 1, NULL, 2.00),
(29, 17, NULL, 204, '家庭幸福餐', 168.00, 1, NULL, 168.00),
(30, 17, 138, NULL, '王老吉', 5.00, 4, NULL, 20.00),
(31, 18, 100, NULL, '辣椒炒肉', 28.00, 2, '{"辣度":"中辣"}', 56.00),
(32, 18, 115, NULL, '麻婆豆腐', 18.00, 1, '{"辣度":"微辣"}', 18.00),
(33, 18, 103, NULL, '可乐', 3.00, 3, NULL, 9.00),
(34, 19, NULL, 205, '商务精英餐', 88.00, 1, NULL, 88.00),
(35, 19, 139, NULL, '加多宝', 5.00, 1, NULL, 5.00),
(36, 20, NULL, 206, '夜宵嗨吃餐', 128.00, 1, NULL, 128.00),
(37, 20, 114, NULL, '小笼包', 20.00, 1, '{"口味":"虾仁"}', 20.00),
(38, 21, 101, NULL, '剁椒鱼头', 68.00, 1, '{"口味":"剁椒"}', 68.00),
(39, 21, 116, NULL, '水煮鱼', 58.00, 1, '{"辣度":"中辣"}', 58.00),
(40, 21, 111, NULL, '清炒时蔬', 18.00, 2, NULL, 36.00),
(41, 22, 105, NULL, '白切鸡', 58.00, 1, '{"口味":"沙姜"}', 58.00),
(42, 22, 106, NULL, '松鼠桂鱼', 88.00, 1, '{"口味":"酸甜"}', 88.00),
(43, 22, 113, NULL, '例汤', 10.00, 1, NULL, 10.00),
(44, 23, 107, NULL, '西湖醋鱼', 48.00, 1, '{"口味":"特甜"}', 48.00),
(45, 23, 111, NULL, '清炒时蔬', 18.00, 1, NULL, 18.00),
(46, 23, 138, NULL, '王老吉', 5.00, 2, NULL, 10.00),
(47, 24, 109, NULL, '葱烧海参', 128.00, 1, '{"口味":"咸鲜"}', 128.00),
(48, 24, 111, NULL, '清炒时蔬', 18.00, 1, NULL, 18.00),
(49, 24, 113, NULL, '例汤', 10.00, 1, NULL, 10.00),
(50, 25, NULL, 207, '早餐元气餐', 18.00, 2, NULL, 36.00),
(51, 25, 140, NULL, '蛋炒饭', 12.00, 1, '{"口味":"酱油"}', 12.00),
(52, 26, 110, NULL, '臭鳜鱼', 78.00, 1, '{"辣度":"特辣"}', 78.00),
(53, 26, 111, NULL, '清炒时蔬', 18.00, 1, NULL, 18.00),
(54, 26, 103, NULL, '可乐', 3.00, 2, NULL, 6.00),
(55, 27, 143, NULL, '酸辣土豆丝', 16.00, 2, '{"辣度":"中辣"}', 32.00),
(56, 27, 144, NULL, '手撕包菜', 18.00, 1, '{"辣度":"微辣"}', 18.00),
(57, 27, 138, NULL, '王老吉', 5.00, 3, NULL, 15.00),
(58, 28, 146, NULL, '皮蛋瘦肉粥', 15.00, 2, NULL, 30.00),
(59, 28, 147, NULL, '叉烧包', 18.00, 1, NULL, 18.00),
(60, 28, 103, NULL, '可乐', 3.00, 2, NULL, 6.00);

-- 14. 操作日志表（operation_log）- 50条测试数据
INSERT INTO `operation_log` (`id`, `operator_id`, `operator_name`, `branch_id`, `module`, `operation_type`, `content`, `ip`, `operation_time`, `status`, `error_msg`)
VALUES
(1, 1, '系统管理员', 1, '系统管理', '其他', 1, '127.0.0.1', '2025-12-13 08:00:00', 1, NULL),
(2, 1, '系统管理员', 1, '系统管理', '其他', 1, '127.0.0.1', '2025-12-13 08:10:00', 1, NULL),
(3, 1, '系统管理员', 1, '系统管理', '其他', 1, '127.0.0.1', '2025-12-13 08:20:00', 1, NULL),
(4, 1, '系统管理员', 1, '系统管理', '其他', 1, '127.0.0.1', '2025-12-13 08:30:00', 1, NULL),
(5, 1, '系统管理员', 1, '系统管理', '其他', 1, '127.0.0.1', '2025-12-13 08:40:00', 1, NULL),
(6, 1, '系统管理员', 1, '系统管理', '其他', 1, '127.0.0.1', '2025-12-13 08:50:00', 1, NULL),
(7, 1, '系统管理员', 1, '系统管理', '其他', 1, '127.0.0.1', '2025-12-13 09:00:00', 1, NULL),
(8, 2, '张店长', 1, '系统管理', '其他', 1, '192.168.1.100', '2025-12-14 08:05:00', 1, NULL),
(9, 2, '张店长', 1, '系统管理', '其他', 1, '192.168.1.100', '2025-12-14 08:15:00', 1, NULL),
(10, 2, '张店长', 1, '系统管理', '其他', 1, '192.168.1.100', '2025-12-14 08:45:00', 1, NULL),
(11, 3, '王收银', 1, '系统管理', '其他', 1, '192.168.1.101', '2025-12-14 09:15:00', 1, NULL),
(12, 4, '李大厨', 1, '系统管理', '其他', 1, '192.168.1.102', '2025-12-14 09:25:00', 1, NULL),
(13, 1, '系统管理员', 1, '系统管理', '其他', 1, '127.0.0.1', '2025-12-13 09:10:00', 1, NULL),
(14, 1, '系统管理员', 1, '系统管理', '其他', 1, '127.0.0.1', '2025-12-13 09:20:00', 1, NULL),
(15, 5, '刘一', 1, '系统管理', '其他', 1, '192.168.1.103', '2025-12-14 09:35:00', 1, NULL),
(16, 6, '陈二', 1, '系统管理', '其他', 1, '192.168.1.104', '2025-12-14 09:45:00', 1, NULL),
(17, 7, '张三', 1, '系统管理', '其他', 1, '192.168.1.105', '2025-12-14 09:55:00', 1, NULL),
(18, 8, '李四', 1, '系统管理', '其他', 1, '192.168.1.106', '2025-12-14 10:05:00', 1, NULL),
(19, 9, '王五', 1, '系统管理', '其他', 1, '192.168.1.107', '2025-12-14 10:15:00', 1, NULL),
(20, 10, '赵六', 1, '系统管理', '其他', 1, '192.168.1.108', '2025-12-14 10:25:00', 1, NULL),
-- 批量补充剩余30条
(21, 1, '系统管理员', 1, '系统管理', '其他', 1, '127.0.0.1', '2025-12-13 09:30:00', 1, NULL),
(22, 1, '系统管理员', 1, '系统管理', '其他', 1, '127.0.0.1', '2025-12-13 09:40:00', 1, NULL),
(23, 2, '张店长', 1, '系统管理', '其他', 1, '192.168.1.100', '2025-12-14 09:50:00', 1, NULL),
(24, 2, '张店长', 1, '系统管理', '其他', 1, '192.168.1.100', '2025-12-14 10:00:00', 1, NULL),
(25, 3, '王收银', 1, '系统管理', '其他', 1, '192.168.1.101', '2025-12-14 10:35:00', 1, NULL),
(26, 4, '李大厨', 1, '系统管理', '其他', 1, '192.168.1.102', '2025-12-14 10:45:00', 1, NULL),
(27, 5, '刘一', 1, '系统管理', '其他', 1, '192.168.1.103', '2025-12-14 10:55:00', 1, NULL),
(28, 6, '陈二', 1, '系统管理', '其他', 1, '192.168.1.104', '2025-12-14 11:05:00', 1, NULL),
(29, 7, '张三', 1, '系统管理', '其他', 1, '192.168.1.105', '2025-12-14 11:15:00', 1, NULL),
(30, 8, '李四', 1, '系统管理', '其他', 1, '192.168.1.106', '2025-12-14 11:25:00', 1, NULL),
(31, 9, '王五', 1, '系统管理', '其他', 1, '192.168.1.107', '2025-12-14 11:35:00', 1, NULL),
(32, 10, '赵六', 1, '系统管理', '其他', 1, '192.168.1.108', '2025-12-14 11:45:00', 1, NULL),
(33, 1, '系统管理员', 1, '系统管理', '其他', 1, '127.0.0.1', '2025-12-13 09:50:00', 1, NULL),
(34, 1, '系统管理员', 1, '系统管理', '其他', 1, '127.0.0.1', '2025-12-13 10:00:00', 1, NULL),
(35, 2, '张店长', 1, '系统管理', '其他', 1, '192.168.1.100', '2025-12-14 11:55:00', 1, NULL),
(36, 2, '张店长', 1, '系统管理', '其他', 1, '192.168.1.100', '2025-12-14 12:05:00', 1, NULL),
(37, 3, '王收银', 1, '系统管理', '其他', 1, '192.168.1.101', '2025-12-14 12:15:00', 1, NULL),
(38, 4, '李大厨', 1, '系统管理', '其他', 1, '192.168.1.102', '2025-12-14 12:25:00', 1, NULL),
(39, 5, '刘一', 1, '系统管理', '其他', 1, '192.168.1.103', '2025-12-14 12:35:00', 1, NULL),
(40, 6, '陈二', 1, '系统管理', '其他', 1, '192.168.1.104', '2025-12-14 12:45:00', 1, NULL),
(41, 7, '张三', 1, '系统管理', '其他', 1, '192.168.1.105', '2025-12-14 12:55:00', 1, NULL),
(42, 8, '李四', 1, '系统管理', '其他', 1, '192.168.1.106', '2025-12-14 13:05:00', 1, NULL);

-- ============================================
-- 15. 登录日志表（login_log）- 50条测试数据（最后一个表）
-- ============================================
USE `deliver_management`;

INSERT INTO `login_log` (`id`, `employee_id`, `username`, `branch_id`, `ip`, `login_time`, `status`, `error_msg`)
VALUES
-- 系统管理员登录（成功）
(1, 1, 'admin', 1, '127.0.0.1', '2025-12-13 08:00:00', 1, NULL),
(2, 1, 'admin', 1, '192.168.1.1', '2025-12-13 09:00:00', 1, NULL),
(3, 1, 'admin', 1, '114.247.50.100', '2025-12-13 10:00:00', 1, NULL),
-- 店长登录（成功+失败）
(4, 2, 'manager', 1, '192.168.1.100', '2025-12-14 07:30:00', 1, NULL),
(5, 2, 'manager', 1, '192.168.1.100', '2025-12-14 07:25:00', 0, '密码错误'),
(6, 2, 'manager', 1, '10.0.0.5', '2025-12-14 12:00:00', 1, NULL),
-- 收银员登录（成功）
(7, 3, 'cashier', 1, '192.168.1.101', '2025-12-14 08:00:00', 1, NULL),
(8, 3, 'cashier', 1, '192.168.1.101', '2025-12-14 14:00:00', 1, NULL),
-- 厨师登录（成功+失败）
(9, 4, 'chef', 1, '192.168.1.102', '2025-12-14 08:30:00', 1, NULL),
(10, 4, 'chef', 1, '192.168.1.102', '2025-12-13 20:00:00', 0, '账号锁定'),
-- 普通员工登录（覆盖多分店/状态）
(11, 5, 'emp001', 1, '192.168.1.103', '2025-12-14 09:00:00', 1, NULL),
(12, 6, 'emp002', 1, '192.168.1.104', '2025-12-14 09:10:00', 1, NULL),
(13, 7, 'emp003', 1, '192.168.1.105', '2025-12-14 09:20:00', 0, '用户名不存在'),
(14, 8, 'emp004', 1, '192.168.1.106', '2025-12-14 09:30:00', 1, NULL),
(15, 9, 'emp005', 1, '192.168.1.107', '2025-12-14 09:40:00', 1, NULL),
(16, 10, 'emp006', 1, '192.168.1.108', '2025-12-14 09:50:00', 1, NULL),
(17, 11, 'emp007', 1, '192.168.1.109', '2025-12-14 10:00:00', 0, '验证码错误'),
(18, 12, 'emp008', 1, '192.168.1.110', '2025-12-14 10:10:00', 1, NULL),
(19, 13, 'emp009', 1, '192.168.1.111', '2025-12-14 10:20:00', 1, NULL),
(20, 14, 'emp010', 1, '192.168.1.112', '2025-12-14 10:30:00', 1, NULL),
-- 批量补充剩余30条（覆盖异地IP/不同失败原因）
(21, 15, 'emp011', 1, '220.181.38.148', '2025-12-14 10:40:00', 1, NULL),
(22, 16, 'emp012', 1, '183.60.212.33', '2025-12-14 10:50:00', 1, NULL),
(23, 17, 'emp013', 1, '119.147.21.199', '2025-12-14 11:00:00', 1, NULL),
(24, 18, 'emp014', 1, '182.131.0.0', '2025-12-14 11:10:00', 0, '密码错误（连续3次）'),
(25, 19, 'emp015', 1, '123.126.97.72', '2025-12-14 11:20:00', 1, NULL),
(26, 20, 'emp016', 1, '111.17.158.88', '2025-12-14 11:30:00', 1, NULL),
(27, 21, 'emp017', 1, '183.221.253.0', '2025-12-14 11:40:00', 1, NULL),
(28, 22, 'emp018', 1, '1.80.124.0', '2025-12-14 11:50:00', 0, 'IP受限'),
(29, 23, 'emp019', 1, '192.168.1.113', '2025-12-14 12:00:00', 1, NULL),
(30, 24, 'emp020', 1, '192.168.1.114', '2025-12-14 12:10:00', 1, NULL),
(31, 25, 'emp021', 1, '192.168.1.115', '2025-12-14 12:20:00', 1, NULL),
(32, 26, 'emp022', 1, '192.168.1.116', '2025-12-14 12:30:00', 0, '账号过期'),
(33, 27, 'emp023', 1, '202.102.100.0', '2025-12-14 12:40:00', 1, NULL),
(34, 28, 'emp024', 1, '218.94.97.0', '2025-12-14 12:50:00', 1, NULL),
(35, 29, 'emp025', 1, '221.204.240.0', '2025-12-14 13:00:00', 1, NULL),
(36, 30, 'emp026', 1, '124.128.0.0', '2025-12-14 13:10:00', 0, '设备未授权'),
(37, 31, 'emp027', 1, '117.136.0.0', '2025-12-14 13:20:00', 1, NULL),
(38, 32, 'emp028', 1, '180.109.0.0', '2025-12-14 13:30:00', 1, NULL),
(39, 33, 'emp029', 1, '122.224.0.0', '2025-12-14 13:40:00', 1, NULL),
(40, 34, 'emp030', 1, '183.148.0.0', '2025-12-14 13:50:00', 0, 'token失效'),
(41, 35, 'emp031', 1, '112.97.0.0', '2025-12-14 14:00:00', 1, NULL),
(42, 36, 'emp032', 1, '14.18.160.0', '2025-12-14 14:10:00', 1, NULL),
(43, 37, 'emp033', 1, '27.40.0.0', '2025-12-14 14:20:00', 1, NULL),
(44, 38, 'emp034', 1, '125.119.0.0', '2025-12-14 14:30:00', 0, '密码错误'),
(45, 39, 'emp035', 1, '61.153.0.0', '2025-12-14 14:40:00', 1, NULL),
(46, 40, 'emp036', 1, '222.186.0.0', '2025-12-14 14:50:00', 1, NULL),
(47, 41, 'emp037', 1, '180.118.0.0', '2025-12-14 15:00:00', 1, NULL),
(48, 42, 'emp038', 1, '58.216.0.0', '2025-12-14 15:10:00', 0, '验证码过期'),
(49, 43, 'emp039', 1, '116.228.0.0', '2025-12-14 15:20:00', 1, NULL),
(50, 44, 'emp040', 1, '218.92.0.0', '2025-12-14 15:30:00', 1, NULL);

-- ============================================
