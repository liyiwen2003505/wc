class AvatarUploader < CarrierWave::Uploader::Base
  # 使用默认的存储方式（本地存储）
  storage :file

  # 保存文件名为原始文件名
  def filename
    original_filename if original_filename
  end

  def store_dir
    "uploads/authors/#{model.id}/avatar" # 你可以根据需要设置路径
  end
end
