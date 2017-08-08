require 'csv'

class ImporterController < ApplicationController
  before_filter :require_login

  #
  def index
  end

  #
  def execute
    # Current user
    @user = User.current

    # uploaded file 
    @file = params[:file]

    # Create issues
    @line_count = 1
    @status_msg = ''
    ic = Iconv.new('UTF-8', l(:general_csv_encoding))
    CSV::IOReader.parse(@file) do |row|
      if (1 < @line_count && 0 < row.size) then

        issue = Issue.find_by_id(row[0]) || Issue.new

        status = IssueStatus.find_by_name(ic.iconv(row[1]))
        project = Project.find_by_name(ic.iconv(row[2]))
        tracker = Tracker.find_by_name(ic.iconv(row[3]))
        assigned_to = User.find_by_login(ic.iconv(row[6]))
        author = User.find_by_login(ic.iconv(row[9]))

        # added import field
        priority = Enumeration.find_by_name(ic.iconv(row[4]))
        category = IssueCategory.find_by_name(ic.iconv(row[7]))
        fixed_version = Version.find_by_name(ic.iconv(row[8]))

        if (row[row.size - 1] == nil || row[row.size - 1].empty?) then
            @status_msg << "Line #{@line_count} : Description can not be empty<br />\n"
        elsif (issue != nil && project != nil && tracker != nil && status != nil) then
              #0 id
              #1 ステータス
                issue.status_id = status.id
              #2 プロジェクト
                issue.project_id = project.id
              #3 トラッカー
                issue.tracker_id = tracker.id
              #4 優先度
              issue.priority_id = priority != nil ? priority.id : ''
              #5 題名
                issue.subject = ic.iconv(row[5])
              #6 担当者
                issue.assigned_to_id = assigned_to != nil ? assigned_to.id : ''
              #7 カテゴリ
              issue.category_id = category != nil ? category.id : ''
              #8 Target version
              issue.fixed_version_id = fixed_version != nil ? fixed_version.id : ''
              #9 起票者
                issue.author_id = author != nil ? author.id : @user.id
              #10 開始日
                issue.start_date = row[10]
              #11 期限日
                issue.due_date = row[11]
              #12 進捗 %
                issue.done_ratio = row[12]
              #13 予定工数
                issue.estimated_hours = row[13]
              #14 作成日
              #15 更新日
              #16 (カスタムフィールド)
              #16- 説明
                issue.description = ic.iconv(row[row.size - 1]);
          if (!issue.save) then
            @status_msg << "Line #{@line_count} : Failed saving.<br />\n"
          end # if
        else # if
          @status_msg << "Line #{@line_count} : Failed saving. Such issue/project/tracker/status not found<br />\n"
        end # if
      end # if
      @line_count += 1
    end # do
  end # execute

end

ImporterController.unloadable
