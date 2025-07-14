const env = {
    development: {
      baseUrl: 'http://localhost:8080'
    },
    production: {
      baseUrl: 'http://api.yanxi.com' // 生产环境API地址
    }
  }

// 根据当前环境选择配置
const config = env[import.meta.env.MODE] || env.development

export default config