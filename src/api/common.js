import request from './index'

/**
 * 通用API
 */

/**
 * 图片上传
 */
export function uploadImage(data) {
  return request({
    url: '/admin/common/upload',
    method: 'post',
    data,
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}

