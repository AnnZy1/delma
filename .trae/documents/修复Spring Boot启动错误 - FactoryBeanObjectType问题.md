## 问题分析

应用程序启动时出现以下错误：
```
java.lang.IllegalArgumentException: Invalid value type for attribute 'factoryBeanObjectType': java.lang.String
```

**根本原因**：Spring Boot 3.2.0及以上版本对FactoryBean的处理方式进行了修改，导致与某些依赖库（如MyBatis-Plus、PageHelper）不兼容。

**解决方案**：将Spring Boot版本升级到3.2.5，该版本已经修复了此问题。

## 修复计划

1. **升级Spring Boot版本**（已完成）
   - 将Spring Boot从3.2.0升级到3.2.5
   - 修改位置：`pom.xml`第11行

2. **重新构建项目**
   - 运行`mvn clean package -DskipTests`确保所有依赖正确下载

3. **验证修复效果**
   - 运行`mvn spring-boot:run`启动应用程序
   - 检查是否成功启动，无上述错误

## 预期结果

应用程序能够成功启动，不再出现"Invalid value type for attribute 'factoryBeanObjectType'"错误。