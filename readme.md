# Panduan Penggunaan KOORD — Export Koordinat AutoCAD ke CSV

**Nama program:** KOORD  
**File program:** `koord.lsp`  
**Perintah AutoCAD:** `KOORD`  
**Keluaran:** CSV (`No,Object,Point,X,Y,Z`)

> Panduan ini disusun berdasarkan pemeriksaan kode `koord.lsp` yang diberikan pengguna. Fungsi-fungsi di bawah merupakan perilaku yang tampak dari kode tersebut, bukan asumsi fitur tambahan.

## 1. Fungsi Program

KOORD adalah program AutoLISP untuk mengambil koordinat dari beberapa objek gambar AutoCAD sekaligus, lalu menyimpannya sebagai file `.csv`. Anda dapat membuka hasilnya di Excel untuk mengolah data koordinat titik survei, posisi pilar, *borehole*, atau elemen denah lainnya.

KOORD **tidak** mengubah atau memindahkan objek CAD. Program ini hanya membaca koordinat dan mengekspornya.

**Penting:** KOORD tidak mengubah UTM menjadi *Latitude–Longitude*. Nilai yang diekspor merupakan koordinat gambar CAD dalam WCS atau UCS yang dipilih. Untuk Google Earth, koordinat UTM masih perlu dikonversi menjadi lintang–bujur atau diproses dengan perangkat GIS.

## 2. Persiapan

1. Simpan `koord.lsp` pada folder yang mudah ditemukan, misalnya `D:\CAD-LISP\koord.lsp`.
2. Buka gambar kerja di AutoCAD yang mendukung AutoLISP.
3. Pastikan gambar memakai sistem koordinat dan satuan yang benar. Jika ingin koordinat UTM, objek harus **sudah digambar pada koordinat UTM sebenarnya**; KOORD tidak melakukan *georeferencing*.
4. Disarankan membuat salinan/cadangan gambar kerja sebelum menggunakan program tambahan.

## 3. Memuat Program ke AutoCAD

1. Pada *command line*, ketik `APPLOAD`, kemudian tekan **Enter**.
2. Pada jendela **Load/Unload Applications**, cari file `koord.lsp`.
3. Pilih file tersebut lalu klik **Load**.
4. Jika berhasil, pada *command line* akan muncul pesan:

   ```text
   Ketik KOORD untuk export koordinat.
   ```

5. Tutup jendela **APPLOAD**.

> Jika AutoCAD menolak pemuatan karena pengaturan keamanan, letakkan file pada folder yang disetujui melalui **Trusted Locations**. Muat hanya file LISP dari sumber yang dipercaya; jangan mematikan fitur keamanan secara sembarangan.

## 4. Cara Menggunakan Perintah KOORD

1. Ketik `KOORD` → **Enter**.
2. Program akan menampilkan judul **EXPORT KOORDINAT MULTI OBJEK** dan pertanyaan:

   ```text
   Gunakan koordinat [WCS/UCS] <WCS>:
   ```

3. Pilih salah satu:
   - **Enter** atau `WCS` → gunakan koordinat global gambar (*World Coordinate System*); **direkomendasikan untuk koordinat survei/UTM**.
   - `UCS` → hasil koordinat dinyatakan terhadap UCS yang **sedang aktif**.
4. Saat muncul:

   ```text
   Pilih objek yang akan diambil koordinatnya:
   ```

   Pilih objek di layar. Anda dapat menggunakan seleksi jendela (*Window/Crossing*) atau memilih beberapa objek, kemudian tekan **Enter** untuk menyelesaikan seleksi.
5. Jendela **Simpan Koordinat** akan muncul. Pilih folder, masukkan nama file `.csv`, lalu klik **Save**.
6. Setelah ekspor selesai, AutoCAD menampilkan jumlah **baris koordinat** yang berhasil ditulis dan lokasi file CSV.

**Contoh urutan perintah:**

```text
Command: APPLOAD
[Load koord.lsp]
Ketik KOORD untuk export koordinat.

Command: KOORD
Gunakan koordinat [WCS/UCS] <WCS>: [Enter]
Pilih objek yang akan diambil koordinatnya: [Pilih objek lalu Enter]
[Jendela Save CSV: tentukan lokasi dan nama file]

EXPORT SELESAI
Jumlah koordinat : [jumlah baris koordinat yang diekspor]
File : [lokasi file CSV]
```

## 5. Jenis Objek yang Dapat Diekspor

| Objek AutoCAD | Isi kolom `Object` | Isi kolom `Point` | Koordinat yang diambil |
|---|---|---|---|
| `POINT` | `POINT` | `P1`, `P2`, ... | Titik objek |
| `INSERT` (block) | `BLOCK` | `P1`, `P2`, ... | Titik penyisipan (*insertion point*) blok |
| `CIRCLE` | `CIRCLE` | `CENTER` | Titik pusat lingkaran |
| `TEXT` | `TEXT` | `INSERTION` | Titik penyisipan teks |
| `MTEXT` | `MTEXT` | `INSERTION` | Titik penyisipan *multiline text* |
| `LINE` | `LINE` | `START` dan `END` | Kedua ujung garis |
| `LWPOLYLINE` | `LWPOLYLINE` | `V1`, `V2`, ... | Seluruh *vertex* polilin |

**Catatan:** Objek yang tidak didukung, seperti `ARC`, `SPLINE`, dan `3D POLYLINE` (`POLYLINE`), **tidak diekspor** oleh versi kode ini. Objek-objek tersebut tidak otomatis menyebabkan program gagal; barisnya hanya tidak ditulis.

## 6. Struktur File CSV

Baris pertama CSV adalah:

```csv
No,Object,Point,X,Y,Z
```

Contoh **ilustratif** (bukan hasil koordinat survei tertentu):

```csv
No,Object,Point,X,Y,Z
1,POINT,P1,288822.816,9813834.248,0.000
2,CIRCLE,CENTER,288815.978,9813863.123,0.000
3,LINE,START,288787.453,9813890.152,0.000
4,LINE,END,288744.814,9813912.495,0.000
```

Arti kolom:

| Kolom | Keterangan |
|---|---|
| `No` | Nomor urut **baris koordinat** hasil ekspor |
| `Object` | Jenis objek yang diekspor |
| `Point` | Jenis titik dari objek tersebut |
| `X` | Koordinat X |
| `Y` | Koordinat Y |
| `Z` | Koordinat Z |

- Program menulis angka hingga **3 angka di belakang titik desimal**.
- Satu `LINE` menghasilkan **2 baris** (`START` dan `END`).
- Satu `LWPOLYLINE` menghasilkan **sejumlah baris sesuai jumlah vertex**.
- Kolom `No` bukan nomor identitas objek AutoCAD; urutannya mengikuti titik-titik yang ditulis.
- Untuk objek `BLOCK`, program tidak mengekspor nama blok atau atribut blok.

## 7. Perbedaan WCS dan UCS

### WCS — Disarankan untuk koordinat asli survei

Pilih **WCS** bila Anda ingin koordinat global objek sebagaimana tersimpan di gambar. Ini paling sesuai untuk pekerjaan CAD yang telah menggunakan **UTM Easting (X), Northing (Y)**.

Memutar **tampilan** (*view twist*) tidak seharusnya mengubah nilai WCS objek. Hindari penggunaan perintah `ROTATE` pada objek jika hanya ingin mengubah arah tampilan.

### UCS — Untuk koordinat relatif terhadap UCS aktif

Pilih **UCS** jika Anda memang ingin hasil koordinat terhadap UCS yang sedang aktif; misalnya UCS lokal yang telah digeser/diputar. Nilai X/Y dapat berbeda dari WCS meskipun posisi objek tidak berubah.

**Perhatian:** Kode hanya mengubah koordinat ke UCS apabila opsi `UCS` dipilih. Ia tidak menyimpan informasi nama UCS atau datum dalam CSV.

## 8. Membuka Hasil di Microsoft Excel

1. Buka Excel, pilih **Data → From Text/CSV**.
2. Pilih file hasil ekspor `Koordinat.csv`.
3. Pastikan pemisah kolom menggunakan **Comma (koma)**.
4. Pastikan tanda desimal dibaca sebagai **titik (`.`)**.
5. Klik **Load**, lalu periksa bahwa `No`, `Object`, `Point`, `X`, `Y`, dan `Z` menjadi enam kolom terpisah.

Apabila angka di Excel menjadi `########`, perlebar kolom. Bila angka terbaca sebagai teks karena pengaturan regional Indonesia, pilih pengaturan *locale* yang sesuai ketika mengimpor CSV; jangan asal mengganti pemisah desimal tanpa mengecek angka sumber.

## 9. Keterbatasan Teknis Versi Saat Ini

1. **Presisi output terbatas pada 0,001 satuan gambar**: kode memakai `(rtos ... 2 3)`. Bila unit gambar meter, ini setara pembulatan ke **1 mm**.
2. **`LWPOLYLINE`: koordinat Z ditulis sebagai `0.000` sebelum transformasi UCS.** Kode tidak mengambil nilai *elevation* polilin (DXF group 38). Karena itu, untuk polilin dengan elevasi sebenarnya, **hasil Z tidak boleh langsung dipercaya**.
3. **Geometri 3D atau objek dengan bidang/normal khusus** belum ditangani secara menyeluruh; verifikasi keluaran pada titik kontrol yang diketahui.
4. Tidak ada pengenal unik objek CAD, handle, layer, nama titik survei, atau atribut blok dalam CSV.
5. Tidak ada konversi zona UTM, datum, maupun UTM → Latitude/Longitude.
6. File CSV baru akan ditulis pada lokasi yang dipilih; gunakan nama berbeda jika tidak ingin menimpa file lama.
7. Urutan titik mengikuti proses pemilihan dan pembacaan objek; **jangan mengandalkan urutannya sebagai urutan trase/geometri**.
8. Opsi `WCS`/`UCS` pada kode bukan pengaturan CRS geodesi (*EPSG*); sistem referensi sebenarnya harus dipastikan terpisah dari file CAD.

## 10. Pemecahan Masalah

| Kendala | Penyebab yang mungkin | Langkah pemeriksaan |
|---|---|---|
| `Unknown command "KOORD"` | LISP belum dimuat pada sesi/gambar aktif | Jalankan `APPLOAD`, muat ulang `koord.lsp`, lalu ketik `KOORD` |
| `Tidak ada objek yang dipilih.` | Seleksi kosong atau dibatalkan | Ulangi perintah dan pilih objek sebelum menekan Enter |
| File CSV kosong selain header | Tidak ada objek yang termasuk jenis yang didukung | Periksa jenis objek menggunakan `LIST`/Properties |
| Jumlah koordinat lebih banyak dari jumlah objek | LINE dan LWPOLYLINE menulis lebih dari satu titik | Periksa kolom `Object` dan `Point` |
| Koordinat X/Y tidak sesuai hasil survei | Gambar memakai koordinat lokal atau opsi UCS dipilih | Periksa satu titik dengan `ID`, kemudian gunakan opsi `WCS` |
| Hasil Excel masuk satu kolom | Pemisah CSV tidak dikenali | Impor lewat **Data → From Text/CSV**, pilih delimiter koma |
| Nilai Z polilin salah atau menjadi nol | Keterbatasan pembacaan elevasi `LWPOLYLINE` | Gunakan verifikasi manual atau revisi LISP agar membaca elevasi/normal objek |
| Tidak muncul dialog penyimpanan | Dialog dibatalkan atau konfigurasi aplikasi berbeda | Jalankan ulang dan pastikan dialog Save muncul |

## 11. Contoh Penerapan untuk Survei Jembatan

Misalnya Anda memiliki denah jembatan dengan objek titik bor, titik pilar, dan garis as jembatan:

1. Pastikan koordinat titik survei di CAD benar-benar sesuai data lapangan (misalnya UTM dengan datum dan zona yang diketahui).
2. Jalankan `KOORD` dan pilih `WCS`.
3. Pilih seluruh objek survei yang diperlukan.
4. Simpan sebagai `Koordinat_Jembatan.csv`.
5. Buka CSV di Excel dan periksa beberapa koordinat kontrol.
6. Jika akan dipakai di Google Earth, **konversikan X/Y UTM ke Latitude–Longitude** menggunakan sistem koordinat asal yang benar. Jangan hanya mengubah judul kolom `X/Y` menjadi `Latitude/Longitude`.

---

**Ringkasnya:** `APPLOAD` → pilih `koord.lsp` → `Load` → ketik `KOORD` → pilih `WCS` atau `UCS` → pilih objek → tentukan nama CSV → selesai.

*Dokumentasi berdasarkan kode KOORD yang diberikan, tanpa mengubah program aslinya.*
