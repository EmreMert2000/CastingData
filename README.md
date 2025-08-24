# Education – SSMS Stored Procedure Hazırlık Reposu

Bu depo, **SQL Server Management Studio (SSMS)** üzerinde *stored procedure* yazımını **öğrenmek ve pratik yapmak** için hazırlandı. Örnekler `dbo.Departments` ve `dbo.Employees` tabloları üzerinde gerçek hayatta sık kullanılan desenleri gösterir.

## İçerik (Prosedürler)
- `usp_Department_Upsert`: Departman ekleme/güncelleme (tek prosedür).
- `usp_Department_List`: Arama ve aktif/pasif filtreli listeleme.
- `usp_Employee_Create`: Çalışan ekleme, FK ve e-posta benzersizliği kontrolü.
- `usp_Employee_Update`: Kısmi güncelleme, opsiyonel **rowversion** eşzamanlılık kontrolü.
- `usp_Employee_SearchPaged`: Ad/soyad/email arama, departman ve tarih filtresi, **sayfalama** ve sıralama.

## Neleri Öğrenirsin?
- `TRY/CATCH`, `XACT_ABORT`, `NOCOUNT`
- Parametreli sorgular, güvenli dinamik `ORDER BY`
- Sayfalama (`OFFSET/FETCH`), toplam satır sayısı döndürme
- FK doğrulama ve iş kuralı hataları (özel hata kodları)
- (İsteğe bağlı) `rowversion` ile eşzamanlı güncelleme

## Başlangıç
1. SSMS ile `Education` veritabanına bağlan.
2. Gerekirse tablo kolonlarını **Şema Keşfi** sorgusu ile kontrol et.
3. `CREATE OR ALTER PROCEDURE` scriptlerini sırayla çalıştır.
4. README’deki örnek çağrıları deneyerek sonucu doğrula.

> Bu repo, **SSMS’te prosedür geliştirmeye hazırlık** amaçlıdır. Kendi alan/kolon adlarına göre küçük uyarlamalar yapman yeterli.
