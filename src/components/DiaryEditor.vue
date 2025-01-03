<template>
    <div class="container">
      <div class="content-wrapper">
        <div class="header">
          <h1>Flomo Memoir</h1>
          <span class="settings-btn" @click="toggleSettings">⚙️</span>
        </div>
        
        <div class="date-header">{{ dateHeader }}</div>
        
        <textarea 
          class="diary-input" 
          placeholder="写下今天的想法..."
          v-model="content"
        ></textarea>
        
        <div class="tag-section">
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
        
        <div class="submit-section">
          <button class="submit-btn" @click="submitDiary" :disabled="isSubmitting">发布</button>
          <transition name="fade">
            <span v-if="showSuccess" class="success-message">✨ 发布成功</span>
          </transition>
        </div>
      </div>

      <SettingsModal 
        v-if="showSettings"
        @close="toggleSettings"
        @save="saveSettings"
      />
    </div>
  </template>
  
  <script setup lang="ts">
  import { ref, computed } from 'vue'
  import SettingsModal from './SettingsModal.vue'
  
  const content = ref('')
  const tags = ref<Set<string>>(new Set())
  const newTag = ref('')
  const tagToDelete = ref('')
  let deleteTimeout: number | null = null
  const showSettings = ref(false)
  const isSubmitting = ref(false)
  const showSuccess = ref(false)
  
  const dateHeader = computed(() => {
    const now = new Date()
    const year = now.getFullYear()
    const month = now.getMonth() + 1
    const day = now.getDate()
    return `#日记/${month}月 ${year}.${month}.${day}`
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
  
  const submitDiary = async () => {
    const apiUrl = localStorage.getItem('apiUrl')
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
  
  const toggleSettings = () => {
    showSettings.value = !showSettings.value
  }
  
  const saveSettings = (apiUrl: string) => {
    localStorage.setItem('apiUrl', apiUrl)
    showSettings.value = false
  }
  </script>
  
  <style scoped>
  .container {
    max-width: 800px;
    margin: 0 auto;
    padding: 40px 20px;
  }

  .content-wrapper {
    width: 100%;
  }

  .header {
    display: flex;
    justify-content: space-between;
    margin-bottom: 20px;
  }

  .settings-btn {
    font-size: 20px;
    cursor: pointer;
    opacity: 0.6;
    transition: opacity 0.3s;
  }

  .settings-btn:hover {
    opacity: 1;
  }

  .date-header {
    font-size: 1.2em;
    color: #666;
    margin-bottom: 10px;
  }

  .diary-input {
    width: 100%;
    height: 300px;
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

  .submit-section {
    position: relative;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 12px;
    margin-top: 20px;
  }

  .success-message {
    position: absolute;
    left: calc(50% + 70px);
    color: #4CAF50;
    font-size: 14px;
  }

  .fade-enter-active,
  .fade-leave-active {
    transition: opacity 0.3s ease;
  }

  .fade-enter-from,
  .fade-leave-to {
    opacity: 0;
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