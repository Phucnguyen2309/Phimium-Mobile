package com.be.controller;

import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/** Browser redirects are navigation only; payment truth comes from the authenticated API. */
@RestController
public class PaymentReturnController {
    @GetMapping(value = {"/payment/success", "/payment/error", "/payment/cancel"}, produces = MediaType.TEXT_HTML_VALUE)
    public ResponseEntity<String> result() {
        return ResponseEntity.ok().header("Cache-Control", "no-store").body("""
                <!doctype html><html lang="vi"><head><meta charset="utf-8">
                <meta name="viewport" content="width=device-width,initial-scale=1">
                <title>Kết quả thanh toán Phimium</title>
                <style>body{font:18px system-ui;background:#faf7f2;color:#20332f;margin:0;padding:40px 20px}
                main{max-width:560px;margin:60px auto}button{padding:12px 20px;font:inherit;cursor:pointer}</style></head>
                <body><main><h1>Phimium</h1><h2 id="status" role="status">Đang kiểm tra thanh toán…</h2>
                <p>Bạn có thể quay lại ứng dụng và mở Đơn đặt tour để xem trạng thái mới nhất.
                Không chuyển tiền lần nữa khi giao dịch đang được xác nhận.</p>
                <button id="check">Kiểm tra lại</button></main>
                <script>
                const statusText = document.getElementById('status');
                const button = document.getElementById('check');
                async function check() {
                  const id = new URLSearchParams(location.search).get('paymentId');
                  if (!id || !/^[0-9a-f-]{36}$/i.test(id)) {
                    statusText.textContent = 'Thiếu mã thanh toán hợp lệ. Vui lòng kiểm tra trong ứng dụng.'; return;
                  }
                  button.disabled = true;
                  try {
                    const response = await fetch('/api/payment/' + encodeURIComponent(id), {credentials:'same-origin', cache:'no-store'});
                    if (response.status === 401 || response.status === 403) {
                      statusText.textContent = 'Vui lòng quay lại ứng dụng để kiểm tra thanh toán.'; return;
                    }
                    if (!response.ok) throw new Error('status unavailable');
                    const data = await response.json();
                    const messages = {PAID:'Thanh toán thành công', PENDING:'Đang chờ xác nhận thanh toán',
                      REVIEW_REQUIRED:'Giao dịch đang được đối soát', EXPIRED:'Thanh toán đã hết hạn',
                      FAILED:'Thanh toán không thành công', CANCELLED:'Thanh toán đã hủy'};
                    statusText.textContent = messages[data.data.status] || 'Vui lòng kiểm tra trạng thái trong ứng dụng.';
                  } catch (_) {statusText.textContent = 'Chưa kiểm tra được trạng thái. Vui lòng thử lại.';}
                  finally {button.disabled = false;}
                }
                button.addEventListener('click', check); check();
                </script></body></html>
                """);
    }
}
