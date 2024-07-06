// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract CargoTrack {

    address public owner;
    error SenderAndReceiverCannotBeSame(); 

    // Oluşturma esnasında sözleşmenin sahibini ayarlar
    constructor() {
        owner = msg.sender;
    }

    mapping(uint256 => Cargo) public cargos;

    struct Cargo {
        uint256 cargoId;
        address sender; // Ethereum address of the sender
        address receiver; // Ethereum address of the recipient
        uint16 weight; // Weight of the cargo
        uint256 createdDate;
        ShippingStatus shippingStatus; // Current status of the shipment
    }

    enum ShippingStatus {
        RECEIVED, // Package is taken at sender
        READY_TO_SHIP, // Package is being prepared for shipment
        IN_TRANSIT, // Package is in transit to its destination
        AT_HUB, // Package is at a sorting/transfer hub
        OUT_FOR_DELIVERY, // Package is on a delivery vehicle
        FAILED_DELIVERY_ATTEMPT, // Delivery attempt was made, but receiver can't find
        DELAYED, // Package is experiencing unexpected delays
        DELIVERED, // Package has been successfully delivered
        RETURNED_TO_SENDER, // Package has been returned to the sender
        LOST, // Package is lost in transit
        DAMAGED // Package was damaged during shipping
    }


    // Durum değişikliği olayı. Frontend tarafından dinlenebilir.
    event ShippingStatusUpdated(uint256 indexed cargoId, ShippingStatus newStatus);

    // Kargo ID'si oluşturur. Gönderen, kargo adı, zaman damgası ve gaz fiyatını kullanarak benzersiz bir ID oluşturur.
    function createCargoId() internal view returns (uint256) {
        uint256 uniqueId = uint256(
            keccak256(abi.encodePacked(msg.sender, block.timestamp, tx.gasprice))
        );
        return uniqueId;
    }
    
    // Yeni bir kargo kaydı oluşturur. Gönderici ve alıcının farklı adresler olmasını sağlar.
    function cargoReceived(
        address _sender,
        address _receiver,
        uint16 _weight
    ) public {
        if (_sender == _receiver) {
            revert SenderAndReceiverCannotBeSame(); 
        }

        uint256 _cargoId = createCargoId();

        cargos[_cargoId] = Cargo({
            cargoId: _cargoId,
            sender: _sender,
            receiver: _receiver,
            weight: _weight,
            createdDate: block.timestamp,
            shippingStatus: ShippingStatus.RECEIVED
        });

        // Kargo durumunun güncellendiğini bildiren bir event yayar.
        emit ShippingStatusUpdated(_cargoId, ShippingStatus.RECEIVED);
        getCargoId(_cargoId);
    }

    function getCargoId(uint256 _cargoId) public pure returns(uint256){
        return _cargoId;
    }

    // Kargo ID'si ile kargo bilgilerini getirir.
    function getCargoById(uint256 _cargoId) public view returns (Cargo memory) {
        return cargos[_cargoId];
    }

    // Kargonun durumunu günceller. Sadece sözleşme sahibi tarafından çağrılabilir.
    // Kargonun durumunu READY_TO_SHIP olarak günceller
    function markReadyToShip(uint256 _cargoId) public onlyOwner {
        _updateStatus(_cargoId, ShippingStatus.READY_TO_SHIP);
    }

    // Kargonun durumunu IN_TRANSIT olarak günceller
    function markInTransit(uint256 _cargoId) public onlyOwner {
        _updateStatus(_cargoId, ShippingStatus.IN_TRANSIT);
    }

    // Kargonun durumunu AT_HUB olarak günceller
    function markAtHub(uint256 _cargoId) public onlyOwner {
        _updateStatus(_cargoId, ShippingStatus.AT_HUB);
    }

    // Kargonun durumunu OUT_FOR_DELIVERY olarak günceller
    function markOutForDelivery(uint256 _cargoId) public onlyOwner {
        _updateStatus(_cargoId, ShippingStatus.OUT_FOR_DELIVERY);
    }

    // Kargonun durumunu FAILED_DELIVERY_ATTEMPT olarak günceller
    function markFailedDeliveryAttempt(uint256 _cargoId) public onlyOwner {
        _updateStatus(_cargoId, ShippingStatus.FAILED_DELIVERY_ATTEMPT);
    }

    // Kargonun durumunu DELAYED olarak günceller
    function markDelayed(uint256 _cargoId) public onlyOwner {
        _updateStatus(_cargoId, ShippingStatus.DELAYED);
    }

    // Kargonun durumunu DELIVERED olarak günceller
    function markDelivered(uint256 _cargoId) public onlyOwner {
        _updateStatus(_cargoId, ShippingStatus.DELIVERED);
        delete cargos[_cargoId]; // Kargo verilerini sil
    }

    // Kargonun durumunu RETURNED_TO_SENDER olarak günceller
    function markReturnedToSender(uint256 _cargoId) public onlyOwner {
        _updateStatus(_cargoId, ShippingStatus.RETURNED_TO_SENDER);
    }

    // Kargonun durumunu LOST olarak günceller
    function markLost(uint256 _cargoId) public onlyOwner {
        _updateStatus(_cargoId, ShippingStatus.LOST);
    }

    // Kargonun durumunu DAMAGED olarak günceller
    function markDamaged(uint256 _cargoId) public onlyOwner {
        _updateStatus(_cargoId, ShippingStatus.DAMAGED);
    }

    // Kargonun durumunu güncelleyen dahili fonksiyon. Sadece sözleşme içinden çağrılabilir.
    function _updateStatus(uint256 _cargoId, ShippingStatus _newStatus) internal onlyOwner {
        // Kargo kaydının varlığını kontrol eder
        require(cargos[_cargoId].cargoId != 0, "The cargo was not found");

        // Kargonun durumunu günceller
        cargos[_cargoId].shippingStatus = _newStatus;

        // Kargo durumunun güncellendiğini bildiren bir event yayar.
        emit ShippingStatusUpdated(_cargoId, _newStatus);
    }

    // Sadece sözleşme sahibinin belirli eylemleri gerçekleştirmesini sağlayan bir değiştirici.
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can do this!");
        _;
    }
    
}
