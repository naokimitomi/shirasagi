module Gws::Share::DescendantsFileInfo
  extend ActiveSupport::Concern
  include ActiveSupport::NumberHelper

  included do
    field :descendants_files_count, type: Integer
    field :descendants_total_file_size, type: Integer

    validate :validate_attached_file_size
    after_save_files :set_file_info, if: -> { file_ids.blank? }

    after_save :update_folder_descendants_file_info, if: -> { file_ids.present? }
    after_destroy_files :update_folder_descendants_file_info, if: -> { file_ids.present? }
  end

  private

  def validate_attached_file_size
    if (limit = (cur_site.share_max_file_size || 0)) > 0
      size = files.compact.map(&:size).max || 0
      if size > limit
        errors.add(
          :base,
          :file_size_exceeds_post_limit,
          size: number_to_human_size(size),
          limit: number_to_human_size(limit))
      end
    end
  end

  def folder_file_info(folder)
    sizes = folder.files.compact.map(&:size) || []
    sizes.compact!

    [ sizes.length, sizes.inject(:+) || 0 ]
  end

  def set_file_info
    files_count, total_file_size = folder_file_info(self)
    self.descendants_files_count = files_count
    self.descendants_total_file_size = total_file_size
  end

  def update_folder_descendants_file_info
#    return unless files
    files_count, total_file_size = folder_file_info(self)
    self.set(
      descendants_files_count: files_count,
      descendants_total_file_size: total_file_size
    )
  end
end

