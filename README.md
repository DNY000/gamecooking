# Phở Phố Cổ: bản chơi thử Godot 4

## Tài liệu

Tài liệu thiết kế game và kế hoạch UI/UX nằm trong thư mục [`docs/`](docs/README.md), có cả bản Markdown và PDF.

## Chạy thử

1. Mở Godot 4 (bản thường, GDScript), chọn **Import** rồi trỏ tới file `project.godot` trong thư mục này.
2. Lần đầu mở, Godot tự nạp toàn bộ hình. Nếu được hỏi nâng cấp dự án lên phiên bản Godot đang dùng, chọn đồng ý.
3. Nhấn **F5** (hoặc nút Play) để chơi. Cửa sổ 1280 × 720, màn hình ngang; chuột thay cho ngón tay.
4. Muốn xem lại hướng dẫn từ đầu: nhấn nút **?**, hoặc xoá file `user://save.cfg` (trong Godot: Project › Open User Data Folder).

## Cách chơi

Lần đầu vào game, bà Tư hướng dẫn từng bước với một khách quen. Nút **?** ở góc trên để xem lại hướng dẫn. Mỗi ngày quán đóng cửa cho tới khi bạn nhấn **Mở cửa đón khách**.

**Xem quán:** kéo để di chuyển, chụm hai ngón (hoặc lăn chuột, chụm trên touchpad) để phóng to, thu nhỏ. Khu bếp ở dưới luôn cố định.

**Nấu một bát phở bò** (kéo thả; chạm cũng được):
1. Chạm **chồng bát** để đặt bát lên thớt (tối đa 3 bát).
2. Kéo **bánh phở** thả vào **rổ chần** trong nồi nước sôi. Thanh trên nồi chạy dần.
3. Khi vạch vào vùng xanh, kéo **rổ chần** đổ bánh vào bát. Sớm quá bánh còn sống, muộn quá bánh nát.
4. Kéo **thịt tái** hoặc **thịt chín** vào bát theo order. Thịt tái nên cho trước khi chan.
5. Kéo **môi** từ nồi nước dùng sang bát, giữ tay để chan; thả tay khi nước tới vạch xanh. Nước nóng làm thịt tái chín tới.
6. Kéo **hành**, **tiêu** vào bát nếu khách gọi.
7. Kéo bát thả vào **khách** (hoặc chạm bát rồi chạm khách). Làm sai thì kéo bát vào **giỏ bỏ bát**.

**Khách:** đi vào theo lối đi, tìm bàn trống và ngồi xuống. Hết bàn thì đứng chờ ở cửa. Ăn xong khách đứng dậy, trả tiền, tip và để lại bát bẩn; chạm vào bàn để dọn. Khách đông lúc 6–9 giờ sáng và 17–21 giờ tối. Nhà phê bình khó tính: sai món là bỏ về, đúng món tip gấp 3. 12 giờ đêm quán đóng cửa và tổng kết, tối đa 5 sao.

## Mã nguồn

- `project.godot`: cấu hình (1920 × 1080, màn hình ngang, renderer Compatibility cho điện thoại).
- `scenes/main.tscn`: cảnh chính.
- `scripts/main.gd`: toàn bộ logic ngày bán hàng, khách, bếp, giao diện.
- `assets/fonts/`: font Be Vietnam Pro (giấy phép OFL) để hiển thị đủ dấu tiếng Việt.

Nền quán hiện vẽ bằng code vì ảnh concept nền đã có sẵn nhân vật trong hình. Khi có ảnh nền quán trống (không người) thì thay vào hàm `_draw_bg`.

---

# Asset concept

66 asset tách từ 4 bảng concept art (tạo ngày 30/10/2026).

## Định dạng

- **PNG 32-bit, nền trong suốt** cho nhân vật, biểu cảm, bộ phận rig và đồ vật. Đây là định dạng Unity, Godot và Spine đọc trực tiếp; không mất chi tiết và giữ được viền mềm.
- **PNG không trong suốt** cho ảnh nền quán (1536 × 1024).
- Kích thước giữ nguyên như khi cắt từ bảng gốc (nhân vật cao khoảng 480 px). Nên coi đây là bản @2x cho điện thoại.
- `assets/manifest.json` liệt kê từng file: tên, nhóm, kích thước.

## Thư mục

```
assets/
  backgrounds/                    nền quán tre mái rơm
  characters/main/                Na (4 góc xoay), bà Tư, Tí
  characters/main/expressions/    6 biểu cảm của Na
  characters/main/rig_parts/      thân, tay, chân của Na để dựng xương
  characters/customers/           9 kiểu khách + mèo
  characters/customers/expressions/  5 mức kiên nhẫn
  items/food/                     6 món
  items/ingredients/              6 nguyên liệu
  items/upgrades/                 nồi, rổ chần, bếp: mỗi thứ 3 cấp (lv1 → lv3)
  items/decor/                    bàn ghế tre và đồ trang trí
  props/                          rổ chần, quạt nan, khay bát phở
concept/                          4 bảng gốc chưa cắt
```

## Lưu ý trước khi dùng trong game

- Đây là asset **để dựng bản chơi thử**. Bản phát hành nên nhờ họa sĩ vẽ lại theo các bảng này.
- Bóng đổ dưới chân và dưới món ăn đã vẽ sẵn vào hình. Nếu engine tự vẽ bóng thì cần xóa phần bóng này.
- Một số khách đứng chồng lên nhau trên bảng gốc nên mép có thể còn sót vài điểm nhỏ. Nên soát lại khi phóng to.
- `rig_parts` chỉ có 5 phần (thân kèm đầu, 2 tay, 2 chân). Để chuyển động mượt cần tách thêm đầu, cẳng tay, bàn tay, tóc và tạp dề thành lớp riêng.
- `stove_lv2` hiện trông giống đèn dầu hơn bếp dầu; cần vẽ lại.
# gamecooking
