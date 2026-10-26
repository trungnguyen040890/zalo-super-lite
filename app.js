var createError = require('http-errors');
var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');

var indexRouter = require('./routes/index');
var chatRouter = require('./routes/chat');

var app = express();

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use('/', indexRouter);
app.use('/chat', chatRouter);


// Ép Express định vị chuẩn thư mục views và public trên môi trường Cloud
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');
app.use(express.static(path.join(__dirname, 'public')));


// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});
// Thử nghiệm gọi trực tiếp trang đăng nhập login.ejs khi vào trang chủ
app.get('/', (req, res) => {
  res.render('login'); 
});

// Thử nghiệm gọi trang index.ejs nếu người dùng vào đường dẫn /index
app.get('/index', (req, res) => {
  res.render('index');
});

module.exports = app;
const PORT = process.env.PORT || 10000;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server is running on port ${PORT}`);
});
// Đảm bảo Express phục vụ các file tĩnh trong thư mục public
app.use(express.static(path.join(__dirname, 'public')));

// Ép trang chủ trả về giao diện login hoặc index
app.get('/', (req, res) => {
  res.render('login'); // Hoặc đổi thành 'login' tùy thuộc vào tên file .ejs của bạn trong thư mục views
});


