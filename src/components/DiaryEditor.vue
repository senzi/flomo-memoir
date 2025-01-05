<template>
  <div class="container">
    <div class="content-wrapper">
      <div class="header">
        <h1>Flomo Memoir</h1>
        <button class="settings-btn" @click="toggleSettings">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <circle cx="12" cy="12" r="8" fill="#42b883"/>
          </svg>
        </button>
      </div>
      
      <div class="date-header">{{ dateHeader }}</div>
      
      <div class="input-wrapper">
        <textarea 
          v-model="content"
          class="diary-input" 
          placeholder="写点什么..."
          @keydown.tab.prevent="handleTab"
        ></textarea>
        <div class="word-count">{{ wordCount }} 字</div>
      </div>
      
      <div class="tag-section">
        <div class="section-title">标签</div>
        <div class="tag-input-container">
          <input 
            type="text" 
            class="tag-input" 
            placeholder="输入标签后按回车添加" 
            @keypress="handleTagInput"
            v-model="newTag"
          >
          <div class="tag-container">
            <span 
              v-for="tag in tags" 
              :key="tag"
              class="tag"
              :class="{ delete: tagToDelete === tag }"
              @click="handleTagClick(tag)"
            >{{ tag }}</span>
          </div>
        </div>
      </div>
      
      <div class="button-group">
        <button @click="reviewDiary" class="review-btn" :disabled="!content || isReviewing">
          {{ isReviewing ? '生成中...' : 'AI 审阅' }}
        </button>
        <button @click="submitDiary" class="submit-btn" :disabled="!content">发布</button>
      </div>

      <div class="submit-section">
        <transition name="fade">
          <span v-if="showSuccess" class="success-message">✨ 发布成功</span>
        </transition>
      </div>

      <div v-if="reviewResult" class="review-result">
        <div class="general-comment">
          <h3>整体评价</h3>
          <p>{{ reviewResult.general_comment }}</p>
        </div>
        
        <div class="suggestions">
          <h3>具体建议</h3>
          <div v-for="(item, index) in reviewResult.suggestions" :key="index" class="suggestion-item">
            <p class="suggestion">{{ item.suggestion }}</p>
            <div class="comparison">
              <div class="original">
                <span class="label">原文：</span>
                <span class="text">{{ item.original }}</span>
              </div>
              <div class="improved">
                <span class="label">建议：</span>
                <span class="text">{{ item.improved }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <SettingsModal 
      v-if="showSettings" 
      @close="showSettings = false"
      @save="saveSettings"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, nextTick } from 'vue'
import SettingsModal from './SettingsModal.vue'
import { reviewDiary as reviewDiaryApi } from '../api/llm'
import { setLocalStorage } from '../utils/storage'

interface ReviewResult {
  general_comment: string
  suggestions: {
    suggestion: string
    original: string
    improved: string
  }[]
}

const content = ref('')
const tags = ref<Set<string>>(new Set())
const newTag = ref('')
const tagToDelete = ref('')
let deleteTimeout: number | null = null
const showSettings = ref(false)
const isSubmitting = ref(false)
const showSuccess = ref(false)
const reviewResult = ref<ReviewResult | null>(null)
const isReviewing = ref(false)

const dateHeader = computed(() => {
  const now = new Date()
  const year = now.getFullYear()
  const month = String(now.getMonth() + 1).padStart(2, '0')
  const day = String(now.getDate()).padStart(2, '0')
  const weekDay = ['日', '一', '二', '三', '四', '五', '六'][now.getDay()]
  return `#25年日记/${month}月 ${year}.${month}.${day} (${weekDay})`
})

const wordCount = computed(() => {
  return content.value.length
})

const handleTagInput = (e: KeyboardEvent) => {
  if (e.key === 'Enter') {
    const tag = newTag.value.trim().replace(/\s+/g, '')
    if (tag && !tags.value.has(tag)) {
      tags.value.add(tag)
      newTag.value = ''
    }
  }
}

const handleTagClick = (tag: string) => {
  if (tagToDelete.value === tag) {
    // 如果标签已经处于待删除状态，点击则删除
    tags.value.delete(tag)
    tagToDelete.value = ''
    if (deleteTimeout) {
      clearTimeout(deleteTimeout)
      deleteTimeout = null
    }
  } else {
    // 设置标签为待删除状态
    tagToDelete.value = tag
    
    // 清除之前的计时器（如果存在）
    if (deleteTimeout) {
      clearTimeout(deleteTimeout)
    }
    
    // 设置新的计时器，1秒后恢复原状
    deleteTimeout = window.setTimeout(() => {
      if (tagToDelete.value === tag) {
        tagToDelete.value = ''
      }
    }, 1000)
  }
}

const handleTab = (e: KeyboardEvent) => {
  const textarea = e.target as HTMLTextAreaElement
  const start = textarea.selectionStart
  const end = textarea.selectionEnd

  content.value = content.value.substring(0, start) + '\t' + content.value.substring(end)
  
  // 保持光标位置在插入的制表符后面
  nextTick(() => {
    textarea.selectionStart = textarea.selectionEnd = start + 1
  })
}

const submitDiary = async () => {
  const apiUrl = localStorage.getItem('apiUrl')?.replace(/^["']|["']$/g, '') // 移除首尾的引号
  if (!apiUrl) {
    alert('请先设置 API URL')
    return
  }

  // 构建内容，包含日期、正文和标签
  const tagsText = Array.from(tags.value).map(tag => `#${tag}`).join(' ')
  const fullContent = `${dateHeader.value}\n${content.value}\n${tagsText}`

  isSubmitting.value = true
  try {
    const response = await fetch(apiUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        content: fullContent
      })
    })

    if (response.ok) {
      content.value = ''
      tags.value.clear()
      showSuccess.value = true
      setTimeout(() => {
        showSuccess.value = false
      }, 2000)
    } else {
      throw new Error('发布失败')
    }
  } catch (error) {
    alert(`发布失败：${error}`)
  } finally {
    isSubmitting.value = false
  }
}

const reviewDiary = async () => {
  if (!content.value || isReviewing.value) return
  
  isReviewing.value = true
  try {
    reviewResult.value = await reviewDiaryApi(content.value, Array.from(tags.value))
  } catch (error) {
    console.error('Failed to review diary:', error)
  } finally {
    isReviewing.value = false
  }
}

const toggleSettings = () => {
  showSettings.value = !showSettings.value
}

const saveSettings = (apiUrl: string, config: any) => {
  setLocalStorage('apiUrl', apiUrl)
  setLocalStorage('llm_config', config)
  showSettings.value = false
}
</script>

<style scoped>
.container {
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
}

.content-wrapper {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 20px;
}

.settings-btn {
  background: transparent;
  border: none;
  padding: 0;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  height: 32px;
  width: 32px;
}

.settings-btn:hover circle {
  fill: #3aa876;
}

.date-header {
  font-size: 1.2em;
  color: #666;
  margin-bottom: 10px;
}

.input-wrapper {
  margin-bottom: 20px;
}

.word-count {
  text-align: right;
  color: #999;
  font-size: 14px;
  margin-top: 8px;
}

.diary-input {
  width: 100%;
  height: 500px;
  padding: 15px;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 16px;
  resize: none;
  background: white;
  margin-bottom: 15px;
  overflow-y: auto;
  scrollbar-width: none;
  -ms-overflow-style: none;
}

.diary-input::-webkit-scrollbar {
  display: none;
}

.tag-section {
  margin-bottom: 15px;
}

.section-title {
  font-size: 14px;
  color: #666;
  margin-bottom: 8px;
}

.tag-input-container {
  display: flex;
  gap: 10px;
  align-items: flex-start;
  min-height: 64px; /* 兼容两行标签的高度 */
}

.tag-input {
  width: 200px;
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
  height: 36px;
}

.tag-container {
  flex: 1;
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  padding-top: 4px;
}

.tag {
  padding: 4px 8px;
  background: #e0e0e0;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.3s;
  margin-bottom: 4px;
}

.tag.delete {
  background: #ff4444;
  color: white;
}

.button-group {
  display: flex;
  justify-content: center;
  gap: 1rem;
  margin: 1.5rem 0;
}

.review-btn {
  padding: 0.6rem 1.2rem;
  background-color: #2196F3;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: background-color 0.3s;
}

.review-btn:hover {
  background-color: #1976D2;
}

.review-btn:disabled {
  background-color: #ccc;
  cursor: not-allowed;
}

.submit-section {
  display: flex;
  align-items: center;
  margin-top: 12px;
}

.success-message {
  display: inline-block;
  background-color: #4CAF50;
  color: white;
  padding: 8px 16px;
  border-radius: 4px;
  margin-left: 12px;
  font-size: 14px;
  animation: fadeIn 0.3s ease-in;
}

.review-result {
  margin: 2rem 0;
  padding: 1.5rem;
  background-color: #f8f9fa;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.general-comment {
  margin-bottom: 1.5rem;
}

.general-comment h3 {
  color: #2196F3;
  margin-bottom: 0.5rem;
}

.suggestions h3 {
  color: #2196F3;
  margin-bottom: 1rem;
}

.suggestion-item {
  margin-bottom: 1.5rem;
  padding-bottom: 1.5rem;
  border-bottom: 1px solid #e0e0e0;
}

.suggestion-item:last-child {
  border-bottom: none;
  margin-bottom: 0;
  padding-bottom: 0;
}

.suggestion {
  color: #333;
  margin-bottom: 0.8rem;
}

.comparison {
  background-color: white;
  padding: 1rem;
  border-radius: 4px;
}

.original, .improved {
  margin: 0.5rem 0;
}

.label {
  color: #666;
  margin-right: 0.5rem;
  font-weight: 500;
}

.text {
  color: #333;
}

.improved .text {
  color: #4CAF50;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

@keyframes fadeIn {
  from { 
    opacity: 0;
    transform: translateY(-4px);
  }
  to { 
    opacity: 1;
    transform: translateY(0);
  }
}

.submit-btn {
  width: 120px;
  padding: 12px;
  background: #4CAF50;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 16px;
}

.submit-btn:hover {
  background: #45a049;
}

.submit-btn:disabled {
  background: #a5d6a7;
  cursor: not-allowed;
}
</style>