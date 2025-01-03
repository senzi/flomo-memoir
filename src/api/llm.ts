import { getLocalStorage } from '../utils/storage'

interface LLMConfig {
  baseUrl: string
  apiKey: string
  model: string
}

interface ReviewResponse {
  general_comment: string
  suggestions: {
    suggestion: string
    original: string
    improved: string
  }[]
}

export const defaultLLMConfig: LLMConfig = {
  baseUrl: 'https://api.moonshot.cn/v1',
  apiKey: '',
  model: 'moonshot-v1-auto'
}

export async function reviewDiary(content: string, tags: string[]): Promise<ReviewResponse> {
  const config = getLocalStorage('llm_config', defaultLLMConfig)
  const tagsText = tags.map(tag => `#${tag}`).join(' ')
  const system_prompt = `
你是一位专业的日记写作指导老师，擅长帮助写作者提升日记的表达质量。你会从叙事结构、细节描写、情感表达和文字表达四个维度来分析和优化日记。
你需要以JSON格式返回修改建议。你的回答应该始终保持温和友善的语气，既要指出需要改进的地方，也要给出具体的优化建议和示例。每个建议都要结合原文，给出切实可行的改进方案。
返回的JSON格式如下：
{
    "general_comment": "50字以内的整体评价",
    "suggestions": [
        {
            "suggestion": "具体修改建议",
            "original": "原文片段",
            "improved": "优化后的内容"
        }
    ]
}
接下来你收到的就是日记初稿全文：
`
  try {
    const requestConfig = {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${config.apiKey}`
      },
      body: JSON.stringify({
        model: config.model,
        messages: [
          {
            role: 'system',
            content: system_prompt
          },
          {
            role: 'user',
            content: `${content}\n\n标签：${tagsText}`
          }
        ],
        temperature: 0.7,
        response_format: { type: 'json_object' }
      })
    }

    const response = await fetch(`${config.baseUrl}/chat/completions`, requestConfig)

    if (!response.ok) {
      const errorData = await response.json().catch(() => null)
      if (response.status === 401) {
        throw new Error('API 密钥无效，请检查设置中的 API Key')
      }
      throw new Error(`API 请求失败: ${errorData?.error?.message || '未知错误'}`)
    }

    const data = await response.json()
    if (!data.choices?.[0]?.message?.content) {
      throw new Error('API 响应格式错误')
    }

    try {
      const content = data.choices[0].message.content
      const parsed = JSON.parse(content)
      return parsed as ReviewResponse
    } catch (e) {
      throw new Error('API 响应解析失败')
    }
  } catch (error) {
    console.error('Failed to review diary:', error)
    throw error
  }
}
