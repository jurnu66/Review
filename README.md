# ระบบล็อกอินและรีวิวภาพยนตร์

## **ภาพรวม**
โปรเจคนี้เป็นระบบรีวิวภาพยนตร์ที่พัฒนาโดยใช้ Ruby on Rails ผู้ใช้สามารถสมัครสมาชิก เข้าสู่ระบบ และเขียนรีวิวภาพยนตร์ได้ ระบบรองรับการยืนยันตัวตนและการจัดการฐานข้อมูลสำหรับผู้ใช้ ภาพยนตร์ และรีวิว

---

## **1. ระบบล็อกอิน**
### **ฟีเจอร์**
- ผู้ใช้สามารถ **สมัครสมาชิก** โดยใช้ **อีเมล** และ **รหัสผ่าน**
- ผู้ใช้สามารถ **เข้าสู่ระบบ** และ **ออกจากระบบ** ได้อย่างปลอดภัย
- รหัสผ่านถูกเข้ารหัสด้วย **BCrypt**
- การยืนยันตัวตนสามารถใช้ **Devise** หรือสร้างระบบล็อกอินเอง

### **การทำงาน**
#### **Model ผู้ใช้** (`app/models/user.rb`)
```ruby
class User < ApplicationRecord
  has_secure_password # ใช้เข้ารหัสรหัสผ่าน
  has_many :reviews, dependent: :destroy
  
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }
end
```

#### **Controller สำหรับล็อกอิน** (`app/controllers/sessions_controller.rb`)
```ruby
class SessionsController < ApplicationController
  def new
  end
  
  def create
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to movies_path, notice: "เข้าสู่ระบบสำเร็จ"
    else
      flash[:alert] = "อีเมลหรือรหัสผ่านไม่ถูกต้อง"
      render :new
    end
  end
  
  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: "ออกจากระบบสำเร็จ"
  end
end
```

#### **เส้นทาง URL** (`config/routes.rb`)
```ruby
Rails.application.routes.draw do
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :users, only: [:new, :create]
  resources :movies do
    resources :reviews, only: [:create, :destroy]
  end
end
```

#### **หน้าล็อกอิน** (`app/views/sessions/new.html.erb`)
```erb
<h2>เข้าสู่ระบบ</h2>
<%= form_with(url: login_path, local: true) do |form| %>
  <p>อีเมล: <%= form.text_field :email %></p>
  <p>รหัสผ่าน: <%= form.password_field :password %></p>
  <%= form.submit "เข้าสู่ระบบ" %>
<% end %>
```

---

## **2. ระบบรีวิวภาพยนตร์**
### **ฟีเจอร์**
- ผู้ใช้สามารถ **เพิ่มรีวิว** ให้กับภาพยนตร์ได้
- รีวิวจะเชื่อมโยงกับ **ภาพยนตร์** และ **ผู้ใช้**
- ผู้ใช้สามารถ **ลบรีวิวของตนเอง** ได้

### **การทำงาน**
#### **Model รีวิว** (`app/models/review.rb`)
```ruby
class Review < ApplicationRecord
  belongs_to :user
  belongs_to :movie
  
  validates :content, presence: true
end
```

#### **Controller สำหรับรีวิว** (`app/controllers/reviews_controller.rb`)
```ruby
class ReviewsController < ApplicationController
  before_action :require_login
  
  def create
    @movie = Movie.find(params[:movie_id])
    @review = @movie.reviews.build(review_params)
    @review.user = current_user
    
    if @review.save
      redirect_to movie_path(@movie), notice: "เพิ่มรีวิวสำเร็จ"
    else
      flash[:alert] = "เกิดข้อผิดพลาดในการเพิ่มรีวิว"
      render 'movies/show'
    end
  end
  
  def destroy
    @review = Review.find(params[:id])
    if @review.user == current_user
      @review.destroy
      redirect_to movie_path(@review.movie), notice: "ลบรีวิวสำเร็จ"
    else
      redirect_to movie_path(@review.movie), alert: "คุณสามารถลบได้เฉพาะรีวิวของตัวเอง"
    end
  end
  
  private
  def review_params
    params.require(:review).permit(:content)
  end
  
  def require_login
    redirect_to login_path unless current_user
  end
end
```

#### **หน้าภาพยนตร์ที่มีรีวิว** (`app/views/movies/show.html.erb`)
```erb
<h2>รีวิว:</h2>
<% if @movie.reviews.any? %>
  <ul>
    <% @movie.reviews.each do |review| %>
      <li>
        <%= review.content %> - <strong><%= review.user.email %></strong>
        <% if review.user == current_user %>
          <%= link_to "ลบ", movie_review_path(@movie, review), method: :delete, data: { confirm: "คุณแน่ใจหรือไม่?" } %>
        <% end %>
      </li>
    <% end %>
  </ul>
<% else %>
  <p>ยังไม่มีรีวิว</p>
<% end %>

<h3>เพิ่มรีวิว:</h3>
<%= form_with(model: [@movie, @movie.reviews.build], local: true) do |form| %>
  <p>รีวิว: <%= form.text_area :content %></p>
  <%= form.submit "ส่งรีวิว" %>
<% end %>
```

---

## **3. การติดตั้งและรันโปรเจค**
### **การติดตั้ง**
1. โคลนโปรเจค:
   ```bash
   git clone https://github.com/jurnu66/Review.git
   cd Review
   ```

2. ติดตั้ง dependencies:
   ```bash
   bundle install
   ```

3. ตั้งค่าฐานข้อมูล:
   ```bash
   rake db:migrate
   rake db:seed  # (ถ้ามีข้อมูลตัวอย่าง)
   ```

4. รันเซิร์ฟเวอร์:
   ```bash
   rails server
   ```

5. เปิดเบราว์เซอร์และเข้าไปที่:
   ```
   http://127.0.0.1:3000
   ```

ตอนนี้คุณสามารถ **สมัครสมาชิก เข้าสู่ระบบ และโพสต์รีวิวได้แล้ว!** 🎬✨

---

## **4. ฟีเจอร์เพิ่มเติมที่อาจเพิ่มในอนาคต**
- ระบบกำหนดสิทธิ์ผู้ใช้ (admin, user ธรรมดา)
- การแบ่งหน้ารีวิว
- ปรับปรุง UI ด้วย Bootstrap หรือ TailwindCSS

หากมีคำถามเพิ่มเติม สามารถติดต่อเราได้! 🚀

