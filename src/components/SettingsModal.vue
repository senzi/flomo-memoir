<template>
    <div class="modal-backdrop" @click="$emit('close')"></div>
    <div class="settings-modal">
      <div class="modal-header">
        <h2>API 设置</h2>
        <button class="close-btn" @click="$emit('close')">×</button>
      </div>
      <div class="modal-content">
        <a href="https://v.flomoapp.com/mine?source=incoming_webhook" 
             target="_blank" 
             rel="noopener noreferrer"
          >点击这里</a> 
          获取你的 API URL。
        <br>
        <p class="guide-text">
          然后在下方输入你的 Flomo API URL。
        </p>
        <input 
          type="text" 
          v-model="apiUrl" 
          placeholder="输入 API URL" 
          class="api-input"
        >
        <button @click="save" class="save-btn">保存</button>
      </div>
    </div>
  </template>
  
  <script setup lang="ts">
  import { ref, onMounted } from 'vue'
  
  const apiUrl = ref('')
  
  onMounted(() => {
    apiUrl.value = localStorage.getItem('apiUrl') || ''
  })
  
  const save = () => {
    emit('save', apiUrl.value)
  }
  
  const emit = defineEmits<{
    (e: 'close'): void
    (e: 'save', url: string): void
  }>()
  </script>
  
  <style scoped>
  .modal-backdrop {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.5);
    z-index: 999;
  }

  .settings-modal {
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    background: white;
    padding: 0;
    border-radius: 12px;
    box-shadow: 0 4px 24px rgba(0,0,0,0.15);
    z-index: 1000;
    width: 480px;
  }

  .modal-header {
    padding: 20px 24px;
    border-bottom: 1px solid #eee;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .modal-header h2 {
    margin: 0;
    font-size: 20px;
    color: #333;
  }

  .close-btn {
    background: none;
    border: none;
    font-size: 24px;
    color: #666;
    cursor: pointer;
    padding: 0;
    width: 32px;
    height: 32px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
  }

  .close-btn:hover {
    background: #f5f5f5;
    color: #333;
  }

  .modal-content {
    padding: 24px;
  }

  .guide-text {
    margin: 0 0 20px;
    color: #666;
    line-height: 1.5;
  }

  .modal-content a {
    color: #4CAF50;
    text-decoration: none;
    background: #e8f5e9;
    padding: 4px 8px;
    border-radius: 4px;
    font-weight: 500;
  }

  .modal-content a:hover {
    background: #c8e6c9;
  }

  .modal-content a:visited {
    color: #4CAF50;
  }

  .api-input {
    width: 100%;
    margin: 0 0 20px;
    padding: 12px;
    border: 1px solid #ddd;
    border-radius: 6px;
    font-size: 14px;
    transition: border-color 0.3s;
  }

  .api-input:focus {
    outline: none;
    border-color: #4CAF50;
  }

  .save-btn {
    width: 100%;
    padding: 12px;
    background: #4CAF50;
    color: white;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    font-size: 16px;
    transition: background 0.3s;
  }

  .save-btn:hover {
    background: #45a049;
  }
  </style>