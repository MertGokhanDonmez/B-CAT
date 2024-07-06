const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CargoTrack", function () {
    let CargoTrack, cargoTrack;
    let owner, addr1, addr2;

    // Test öncesi çalişacak fonksiyon. Her testten önce sözleşmeyi ve hesaplari başlatir.
    beforeEach(async function () {
        // Sözleşmeyi derle ve dağit
        CargoTrack = await ethers.getContractFactory("CargoTrack");
        [owner, addr1, addr2] = await ethers.getSigners(); // Test hesaplarini al
        cargoTrack = await CargoTrack.deploy();
        await cargoTrack.deployed();
    });

    it("Sözleşme sahibini doğru bir şekilde ayarlamalidir", async function () {
        expect(await cargoTrack.owner()).to.equal(owner.address);
    });

    it("Yeni bir kargo kaydi oluşturmalidir", async function () {
        const cargoWeight = 1000; // gram

        // cargoReceived fonksiyonunu çağir ve olayi bekle
        const tx = await cargoTrack.cargoReceived(
            addr1.address,
            addr2.address,
            cargoWeight
        );
        const receipt = await tx.wait(); // İşlemin onaylanmasini bekle

        // Olaydan cargoID'yi al
        const cargoID = receipt.events[0].args[0]; 

        // Kargonun bilgilerini alirken doğru cargoID'yi kullan
        const cargo = await cargoTrack.getCargoById(cargoID); 

        // Kargonun bilgilerini doğrula
        expect(cargo.cargoId).to.eq(cargoID); // Doğru cargoID değerini kullan
        expect(cargo.sender).to.equal(addr1.address);
        expect(cargo.receiver).to.equal(addr2.address);
        expect(cargo.weight).to.equal(cargoWeight);
        expect(cargo.shippingStatus).to.equal(0); // RECEIVED
    });

    it("Gönderen ve alici ayni olduğunda hata vermelidir", async function () {
        await expect(
            cargoTrack.cargoReceived(addr1.address, addr1.address, 1000)
        ).to.be.revertedWith("SenderAndReceiverCannotBeSame");
    });

    it("Kargonun durumunu güncellemelidir", async function () {
        // Bir kargo oluştur
        await cargoTrack.cargoReceived(addr1.address, addr2.address, 1000);

        // Kargonun durumunu IN_TRANSIT (2) olarak güncelle
        await expect(cargoTrack.markInTransit(1))
            .to.emit(cargoTrack, "ShippingStatusUpdated")
            .withArgs(1, 2);

        // Kargonun güncellenmiş durumunu kontrol et
        const cargo = await cargoTrack.getCargoById(1);
        expect(cargo.shippingStatus).to.equal(2);
    });

    it("Kargonu başariyla teslim edildikten sonra verilerini silmelidir", async function () {
        await cargoTrack.cargoReceived(addr1.address, addr2.address, 1000);

        // Kargonun durumunu DELIVERED olarak işaretle
        await cargoTrack.markDelivered(cargoID);
        try {
            await cargoTrack.getCargoById(cargoID);
            // Eğer buraya ulaşırsa test başarısız olmalı
            expect.fail("Expected an error, but getCargoById() did not revert.");
        } catch (error) {
            // Hata mesajını kontrol et (opsiyonel)
            expect(error.message).to.include("The cargo was not found"); 
        }

        // Kargonun artik var olmadiğini kontrol et
        await expect(cargoTrack.getCargoById(cargoID)).to.be.reverted;
    });

    // Örnek: Sadece sözleşme sahibi kargonun durumunu güncelleyebilir
    it("Başka bir kullanici kargonun durumunu güncelleyememelidir", async function () {
        await cargoTrack.cargoReceived(addr1.address, addr2.address, 1000);

        // addr1 kullanarak kargonun durumunu güncellemeyi dene
        await expect(cargoTrack.connect(addr1).markInTransit(1)).to.be.revertedWith(
            "Sadece sozlesme sahibi bu islemi gerceklestirebilir"
        );
    });

});