# Add a declarative step here for populating the DB with movies.

Given(/^the following movies exist:$/) do |table|
  table.hashes.each do |movie|
    Movie.create!(movie)
  end
end


Then(/(.*) seed movies should exist/) do |n_seeds|
  expect(Movie.count).to eq n_seeds.to_i
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then(/I should see "(.*)" before "(.*)"/) do |_e1, _e2|
  #  ensure that that e1 occurs before e2.
  #  page.body is the entire content of the page as a string.
  #pending "Fill in this step in movie_steps.rb"
end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When(/I (un)?check the following ratings: (.*)/) do |_uncheck, _rating_list|
  # HINT: use String#split to split up the rating_list, then
  #   iterate over the ratings and reuse the "When I check..." or
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb
  #pending "Fill in this step in movie_steps.rb"
end

# Part 2, Step 3
Then(/^I should (not )?see the following movies: (.*)$/) do |_no, _movie_list|
  # Take a look at web_steps.rb Then /^(?:|I )should see "([^"]*)"$/
  #pending "Fill in this step in movie_steps.rb"
end

Then(/I should see all the movies/) do
  # Make sure that all the movies in the app are visible in the table
  #pending "Fill in this step in movie_steps.rb"
end

### Utility Steps Just for this assignment.

Then(/^debug$/) do
  # Use this to write "Then debug" in your scenario to open a console.
  require "byebug"
  byebug
  1 # intentionally force debugger context in this method
end

Then(/^debug javascript$/) do
  # Use this to write "Then debug" in your scenario to open a JS console
  page.driver.debugger
  1
end

Then(/complete the rest of of this scenario/) do
  # This shows you what a basic cucumber scenario looks like.
  # You should leave this block inside movie_steps, but replace
  # the line in your scenarios with the appropriate steps.
  raise "Remove this step from your .feature files"
end
#------------------------------------
#เพิ่มเชื่อมกับsort_movie_list.Feature
Then('I should see movies sorted alphabetically:') do |table|
  # ดึงรายชื่อภาพยนตร์ที่แสดงผลในหน้าเว็บ
  displayed_titles = page.all('table#movies tbody tr td:first-child').map(&:text)
  # แปลงข้อมูลใน DataTable ของ Cucumber เป็น Array
  expected_titles = table.raw.flatten.drop(1)
  ##expected_titles = table.raw.flatten
  # ตรวจสอบว่ารายชื่อที่แสดงผลเรียงลำดับตามที่คาดหวังหรือไม่
  expect(displayed_titles).to eq(expected_titles)
end


Then('I should see movies sorted by release date:') do |table|
  # ดึงวันที่จากหน้าเว็บ
  displayed_dates = page.all('table#movies tbody tr td:nth-child(3)').map(&:text)

  # ข้ามหัวตาราง (row[0]) และแปลงวันที่ในฟีเจอร์ไฟล์เป็น ISO Format
  expected_dates = table.raw.drop(1).flatten.map do |date|
    begin
      Date.strptime(date, '%d-%b-%Y').strftime('%Y-%m-%d 00:00:00 UTC')
    rescue ArgumentError => e
      raise "Invalid date format in feature file: #{date}"
    end
  end

  # ตรวจสอบความถูกต้องของข้อมูล
  if displayed_dates.empty?
    raise "No dates found on the page. Check your HTML table structure or selectors."
  end

  # เปรียบเทียบ
  expect(displayed_dates).to eq(expected_dates)
end


#Then('I should see movies sorted by release date:') do |table|
  # ดึงวันที่ที่แสดงผลในหน้าเว็บ
  #displayed_dates = page.all('table#movies tbody tr td:nth-child(3)').map(&:text)
  # แปลงข้อมูลใน DataTable ของ Cucumber เป็น Array
  #expected_dates = table.raw.flatten
  # ตรวจสอบว่าลำดับวันที่ที่แสดงผลตรงตามที่คาดหวังหรือไม่
  #expect(displayed_dates).to eq(expected_dates)
#end


