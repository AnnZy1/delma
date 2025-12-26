package com.delivery.management.dto;

import lombok.Data;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import java.io.Serializable;
import java.util.List;

/**
 * 菜品批量操作DTO
 * 
 * @author system
 * @date 2025-01-15
 */
@Data
public class DishBatchDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 菜品ID列表
     */
    private List<Long> ids;

    /**
     * 操作类型：enable-启售 disable-停售
     */
    private String operation;
}

