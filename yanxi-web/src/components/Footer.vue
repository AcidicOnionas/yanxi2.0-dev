<template>
  <footer class="site-footer">
    <div class="footer-main">
      <div class="footer-col">
        <div class="footer-title brand-title">言磎精品中文</div>
        <div class="footer-desc">快乐学习语文数学！</div>
      </div>
      <div class="footer-col">
        <div class="footer-title">链接</div>
        <a href="/">主页</a>
        <a href="/about">介绍</a>
        <a href="/courses">课程</a>
      </div>
      <div class="footer-col">
        <div class="footer-title">联系我们</div>
        <a class="footer-mail" href="mailto:chenxuhong1212@icloud.com">chenxuhong1212@icloud.com</a>
      </div>
      <!-- <div class="footer-col">
        <div class="footer-title">Connect With Us</div>
        <div class="footer-social">
          <a href="#" aria-label="Facebook">
            <svg width="24" height="24" fill="currentColor" viewBox="0 0 24 24"><path d="M22.675 0h-21.35C.595 0 0 .592 0 1.326v21.348C0 23.408.595 24 1.325 24h11.495v-9.294H9.692v-3.622h3.128V8.413c0-3.1 1.893-4.788 4.659-4.788 1.325 0 2.463.099 2.797.143v3.24l-1.918.001c-1.504 0-1.797.715-1.797 1.763v2.313h3.587l-.467 3.622h-3.12V24h6.116C23.406 24 24 23.408 24 22.674V1.326C24 .592 23.406 0 22.675 0"></path></svg>
          </a>
          <a href="#" aria-label="Twitter">
            <svg width="24" height="24" fill="currentColor" viewBox="0 0 24 24"><path d="M24 4.557a9.83 9.83 0 0 1-2.828.775 4.932 4.932 0 0 0 2.165-2.724c-.951.564-2.005.974-3.127 1.195a4.916 4.916 0 0 0-8.38 4.482C7.691 8.095 4.066 6.13 1.64 3.161c-.542.929-.856 2.01-.857 3.17 0 2.188 1.115 4.117 2.823 5.254a4.904 4.904 0 0 1-2.229-.616c-.054 2.281 1.581 4.415 3.949 4.89a4.936 4.936 0 0 1-2.224.084c.627 1.956 2.444 3.377 4.6 3.417A9.867 9.867 0 0 1 0 21.543a13.94 13.94 0 0 0 7.548 2.209c9.058 0 14.009-7.496 14.009-13.986 0-.21 0-.423-.016-.634A9.936 9.936 0 0 0 24 4.557z"></path></svg>
          </a>
          <a href="#" aria-label="Instagram">
            <svg width="24" height="24" fill="currentColor" viewBox="0 0 24 24"><path d="M12 2.163c3.204 0 3.584.012 4.85.07 1.366.062 2.633.334 3.608 1.308.974.974 1.246 2.241 1.308 3.608.058 1.266.07 1.646.07 4.85s-.012 3.584-.07 4.85c-.062 1.366-.334 2.633-1.308 3.608-.974.974-2.241 1.246-3.608 1.308-1.266.058-1.646.07-4.85.07s-3.584-.012-4.85-.07c-1.366-.062-2.633-.334-3.608-1.308-.974-.974-1.246-2.241-1.308-3.608C2.175 15.647 2.163 15.267 2.163 12s.012-3.584.07-4.85c.062-1.366.334-2.633 1.308-3.608.974-.974 2.241-1.246 3.608-1.308C8.416 2.175 8.796 2.163 12 2.163zm0-2.163C8.741 0 8.332.013 7.052.072 5.775.131 4.602.425 3.635 1.392 2.668 2.359 2.374 3.532 2.315 4.809 2.256 6.089 2.243 6.498 2.243 12c0 5.502.013 5.911.072 7.191.059 1.277.353 2.45 1.32 3.417.967.967 2.14 1.261 3.417 1.32 1.28.059 1.689.072 7.191.072s5.911-.013 7.191-.072c1.277-.059 2.45-.353 3.417-1.32.967-.967 1.261-2.14 1.32-3.417.059-1.28.072-1.689.072-7.191s-.013-5.911-.072-7.191c-.059-1.277-.353-2.45-1.32-3.417C19.55.425 18.377.131 17.1.072 15.82.013 15.411 0 12 0zm0 5.838a6.162 6.162 0 1 0 0 12.324 6.162 6.162 0 0 0 0-12.324zm0 10.162a3.999 3.999 0 1 1 0-7.998 3.999 3.999 0 0 1 0 7.998zm6.406-11.845a1.44 1.44 0 1 0 0 2.881 1.44 1.44 0 0 0 0-2.881z"></path></svg>
          </a>
        </div>
      </div> -->
    </div>
    <hr class="footer-line" />
    <div class="footer-bottom">
      © 2025 言磎精品中文. All rights reserved.
    </div>
  </footer>
</template>

<style scoped>
.site-footer {
  background: linear-gradient(135deg, #101820 60%, #1a2636 100%);
  color: #fff;
  padding: 48px 0 24px 0;
  width: 100vw;
  position: relative;
  left: 50%;
  right: 50%;
  margin-left: -50vw;
  margin-right: -50vw;
  margin-top: auto;
  box-shadow: 0 -2px 16px 0 rgba(0,0,0,0.08);
}
.footer-main {
  display: flex;
  justify-content: center;
  gap: 100px;
  max-width: 1200px;
  margin: 0 auto 24px auto;
  flex-wrap: wrap;
}
.footer-col {
  display: flex;
  flex-direction: column;
  gap: 12px;
  min-width: 160px;
}
.footer-title {
  font-size: 1.2rem;
  font-weight: bold;
  margin-bottom: 8px;
  color: #fff;
  letter-spacing: 1px;
}
.brand-title {
  font-size: 1.4rem;
  color: #ffb300;
  letter-spacing: 2px;
}
.footer-desc {
  color: #b0b8c1;
  font-size: 1rem;
}
.footer-col a {
  color: #e0e6ed;
  text-decoration: none;
  font-size: 1rem;
  margin-bottom: 4px;
  transition: color 0.2s, text-shadow 0.2s;
}
.footer-col a:hover {
  color: #fff;
  text-shadow: 0 2px 8px #ffb30044;
}
.footer-social a {
  font-size: 1.6rem;
  margin-right: 16px;
  color: #e0e6ed;
  transition: color 0.2s, transform 0.2s;
  display: inline-flex;
  align-items: center;
}
.footer-social a:hover {
  color: #ffb300;
  transform: scale(1.2) rotate(-8deg);
}
.footer-line {
  border: none;
  border-top: 1px solid #222c36;
  margin: 24px auto;
  max-width: 100%;
}
.footer-bottom {
  text-align: left;
  color: #b0b8c1;
  font-size: 1rem;
  max-width: 1200px;
  margin: 0 auto;
}
.footer-mail {
  color: #ffb300;
  font-weight: bold;
  text-decoration: none;
  font-size: 1rem;
  margin-top: 4px;
  transition: color 0.2s;
}
.footer-mail:hover {
  color: #fff;
  text-decoration: underline;
}
@media (max-width: 900px) {
  .footer-main {
    gap: 40px;
  }
}
@media (max-width: 600px) {
  .footer-main {
    flex-direction: column;
    align-items: flex-start;
    gap: 24px;
    padding: 0 16px;
  }
  .footer-bottom {
    text-align: center;
    padding: 0 16px;
  }
}
</style> 