const env = {
    development: {
      baseUrl: 'http://baf8-70-95-66-181.ngrok-free.app'
    },
    production: {
      baseUrl: 'http://baf8-70-95-66-181.ngrok-free.app'
    }
  }

// 根据当前环境选择配置
const config = env[import.meta.env.MODE] || env.development

export default config