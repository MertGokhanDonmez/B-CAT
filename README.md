# CargoTrack Sözleşmesi - Dokümantasyon

Bu Solidity sözleşmesi, kargo takip sistemini Ethereum blok zincirinde uygulamak için tasarlanmıştır. Sözleşme, kargo oluşturma, durumunu güncelleme ve kargo bilgilerini alma gibi işlevleri sağlar.

## Sözleşme Detayları

- **Sözleşme Adı:** `CargoTrack`
- **Solidity Versiyonu:** `^0.8.25`
- **Lisans:** `MIT`

## Fonksiyonlar

**1. `constructor()`**

- Sözleşme oluşturulduğunda çalışır ve sözleşmenin sahibini ayarlar.

**2. `cargoReceived(address _sender, address _receiver, uint16 _weight)`**

- Yeni bir kargo kaydı oluşturur.
- `_sender`: Kargonun göndericisinin Ethereum adresi.
- `_receiver`: Kargonun alıcısının Ethereum adresi.
- `_weight`: Kargonun ağırlığı.
- Gönderici ve alıcının aynı adresler olmasını engeller.
- Yeni bir kargo ID'si oluşturur.
- Kargo bilgilerini depolar ve durumunu "RECEIVED" (Teslim Alındı) olarak ayarlar.
- `"ShippingStatusUpdated"` olayını tetikler.

**3. `getCargoId(uint256 _cargoId)`**

- Verilen kargo ID'sini döndürür.

**4. `getCargoById(uint256 _cargoId)`**

- Verilen kargo ID'sine ait kargo bilgilerini döndürür.
- `_cargoId`: Sorgulanacak kargonun ID'si.

**5. Durum Güncelleme Fonksiyonları**

- Aşağıdaki fonksiyonlar, kargonun durumunu güncellemek için kullanılır. Bu fonksiyonlar sadece sözleşme sahibi tarafından çağrılabilir.
    - `markReadyToShip(uint256 _cargoId)`: Kargo "READY_TO_SHIP" (Gönderime Hazır) durumuna geçirilir.
    - `markInTransit(uint256 _cargoId)`: Kargo "IN_TRANSIT" (Yolda) durumuna geçirilir.
    - `markAtHub(uint256 _cargoId)`: Kargo "AT_HUB" (Aktarma Merkezinde) durumuna geçirilir.
    - `markOutForDelivery(uint256 _cargoId)`: Kargo "OUT_FOR_DELIVERY" (Teslimata Çıktı) durumuna geçirilir.
    - `markFailedDeliveryAttempt(uint256 _cargoId)`: Kargo "FAILED_DELIVERY_ATTEMPT" (Teslimat Girişimi Başarısız) durumuna geçirilir.
    - `markDelayed(uint256 _cargoId)`: Kargo "DELAYED" (Gecikmeli) durumuna geçirilir.
    - `markDelivered(uint256 _cargoId)`: Kargo "DELIVERED" (Teslim Edildi) durumuna geçirilir ve kargo bilgileri silinir.
    - `markReturnedToSender(uint256 _cargoId)`: Kargo "RETURNED_TO_SENDER" (Göndericiye İade Edildi) durumuna geçirilir.
    - `markLost(uint256 _cargoId)`: Kargo "LOST" (Kayıp) durumuna geçirilir.
    - `markDamaged(uint256 _cargoId)`: Kargo "DAMAGED" (Hasarlı) durumuna geçirilir.
- Tüm bu fonksiyonlar `"ShippingStatusUpdated"` olayını tetikler.

**6. `_updateStatus(uint256 _cargoId, ShippingStatus _newStatus)`**

- Kargonun durumunu güncellemek için kullanılan dahili fonksiyon. Sadece sözleşme içinden çağrılabilir.
- Kargo kaydının varlığını kontrol eder.
- Kargonun durumunu günceller.
- `"ShippingStatusUpdated"` olayını tetikler.

## Olaylar

**`ShippingStatusUpdated(uint256 indexed cargoId, ShippingStatus newStatus)`**

- Bir kargonun durumu güncellendiğinde tetiklenir.
- Frontend uygulamalar bu olayı dinleyerek arayüzü güncelleyebilir.

## Değiştiriciler

**`onlyOwner()`**

- Sadece sözleşme sahibinin belirli eylemleri gerçekleştirmesini sağlar.

## Veri Yapıları

**`Cargo` (Struct)**

- Kargo bilgilerini tutmak için kullanılan bir yapı.
    - `cargoId`: Kargonun ID'si.
    - `sender`: Göndericinin Ethereum adresi.
    - `receiver`: Alıcının Ethereum adresi.
    - `weight`: Kargonun ağırlığı.
    - `createdDate`: Kargonun oluşturulma tarihi.
    - `shippingStatus`: Kargonun geçerli durumu.

**`ShippingStatus` (Enum)**

- Kargonun olası durumlarını tanımlar.
    - `RECEIVED`: Kargo teslim alındı.
    - `READY_TO_SHIP`: Kargo gönderime hazır.
    - `IN_TRANSIT`: Kargo yolda.
    - `AT_HUB`: Kargo aktarma merkezinde.
    - `OUT_FOR_DELIVERY`: Kargo teslimata çıktı.
    - `FAILED_DELIVERY_ATTEMPT`: Teslimat girişimi başarısız.
    - `DELAYED`: Kargo gecikmeli.
    - `DELIVERED`: Kargo teslim edildi.
    - `RETURNED_TO_SENDER`: Kargo göndericiye iade edildi.
    - `LOST`: Kargo kayıp.
    - `DAMAGED`: Kargo hasarlı.
