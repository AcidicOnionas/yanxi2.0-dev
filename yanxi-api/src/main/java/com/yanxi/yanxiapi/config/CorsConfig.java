package com.yanxi.yanxiapi.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

/**
 * CORS配置
 */
@Configuration
public class CorsConfig {
    
    @Bean
    public CorsFilter corsFilter() {
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        CorsConfiguration config = new CorsConfiguration();
        
        // 允许跨域的源
        config.addAllowedOrigin("http://localhost:5173"); // Vue开发服务器默认端口
        config.addAllowedOrigin("http://localhost:3000"); // 其他可能的前端端口
        config.addAllowedOriginPattern("http://*"); // Allow any HTTP origin (for development)
        config.addAllowedOriginPattern("https://*"); // Allow any HTTPS origin
        
        // 允许跨域的请求头
        config.addAllowedHeader("*");
        
        // 允许跨域的请求方法
        config.addAllowedMethod("*");
        
        // 允许携带cookie
        config.setAllowCredentials(true);
        
        // 暴露响应头
        config.addExposedHeader("*");
        
        source.registerCorsConfiguration("/**", config);
        return new CorsFilter(source);
    }
} 