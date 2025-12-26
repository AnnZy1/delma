package com.delivery.management.dto;

import lombok.Data;
import java.io.Serializable;
import java.util.List;

/**
 * 分类批量操作DTO
 * 
 * @author system
 * @date 2025-01-15
 */
@Data
public class CategoryBatchDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 分类ID列表
     */
    private List<Long> ids;

    /**
     * 操作类型：enable-启用 disable-禁用
     */
    private String operation;
}

