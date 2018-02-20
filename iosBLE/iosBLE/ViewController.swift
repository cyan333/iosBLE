//
//  ViewController.swift
//  iosBLE
//
//  Created by NingFangming on 1/21/18.
//  Copyright © 2018 fangming. All rights reserved.
//

import UIKit
import Charts
import CoreBluetooth
 

class ViewController: UIViewController,
                        CBCentralManagerDelegate,
                        CBPeripheralDelegate{
    
    @IBOutlet var oxgTxt: UILabel!
    @IBOutlet var hrbTxt: UILabel!
    @IBOutlet var tempTxt: UILabel!
    @IBOutlet var ecgHRBTxt: UILabel!
    
    @IBOutlet var lineChartView_ECG: LineChartView!
    @IBOutlet var lineChartView_PPG: LineChartView!
    
    @IBAction func saveButton_ECG(_ sender: UIButton) {
        print("ECG pressed")
        sender.setTitle("Saving", for: .normal)
        let image = lineChartView_ECG.getChartImage(transparent: false)
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        sender.setTitle("Save", for: .normal)
    }
    
    
    @IBAction func saveButton_PPG(_ sender: UIButton) {
        print("PPG pressed")
        sender.setTitle("Saving", for: .normal)
        let image = lineChartView_PPG.getChartImage(transparent: false)
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        sender.setTitle("Save", for: .normal)
    }
    
    var currentState = CurrentState.Waiting
    
    var ppgRedBuffer = [Int32]()
    var ppgIrBuffer =  [Int32]()
//    var tempBuffer : [Int32] = [-3734,-3577,-3505,-3458,-3354,-3347,-4012,-4978,-5414,-5311,-5080,-4891,-4691,-4638,-4676,-4662,-4505,-4270,-4059,-3867,-3703,-3616,-3545,-3439,-3370,-3466,-4395,-5321,-5537,-5349,-5166,-5017,-3427,-3341,-3258,-3199,-3155,-3143,-3112,-3095,-3073,-3332,-3955,-4105,-3863,-3642,-3507,-3408,-3400,-3395,-3349,-3292,-3215,-3163,-3135,-3131,-3112,-3085,-3086,-3405,-4103,-4275,-4095,-3883,-3740,-3637,-3613,-3649,-3621,-3520,-3430,-3362,-3311,-3283,-3263,-3242,-3213,-3257,-3910,-4485,-4508,-4296,-4097,-3951,-3861,-3893,-3930,-3879,-3753,-3631,-3547,-3490,-3455,-3465,-3420,-3363,-3323,-3279,-3421,-4298]
//
//    var tempBufferR : [Int32] = [-16654,-16594,-16570,-16550,-16508,-16495,-16736,-17110,-17271,-17244,-17151,-17091,-17007,-16986,-17011,-17000,-16942,-16856,-16769,-16692,-16633,-16599,-16568,-16526,-16503,-16534,-16874,-17223,-17304,-17244,-17176,-17120,-17120,-17096,-17075,-17053,-17037,-17043,-17034,-17025,-17022,-17118,-17316,-17369,-17282,-17215,-17175,-17135,-17144,-17143,-17133,-17125,-17094,-17076,-17073,-17073,-17063,-17060,-17058,-17167,-17409,-17464,-17402,-17326,-17277,-17246,-17238,-17246,-17244,-17212,-17188,-17167,-17153,-17145,-17146,-17132,-17125,-17143,-17355,-17550,-17561,-17488,-17415,-17363,-17341,-17345,-17358,-17348,-17310,-17274,-17244,-17219,-17218,-17216,-17197,-17191,-17169,-17160,-17199,-17496]
    
//    var tempBuffer : [Int32] = [-13475 ,-13389 ,-13355 ,-13354 ,-13335 ,-13326 ,-13308 ,-13286 ,-13267 ,-13250 ,-13243 ,-13292 ,-13552 ,-13741 ,-13662 ,-13499 ,-13415 ,-13354 ,-13333 ,-13330 ,-13321 ,-13321 ,-13319 ,-13307 ,-13299 ,-13294 ,-13371 ,-13755 ,-13989 ,-13941 ,-13770 ,-13621 ,-16838 ,-16878 ,-16871 ,-16841 ,-16803 ,-16773 ,-16746 ,-16730 ,-16718 ,-16701 ,-16764 ,-16929 ,-17026 ,-17019 ,-16966 ,-16917 ,-16872 ,-16879 ,-16902 ,-16915 ,-16893 ,-16846 ,-16796 ,-16780 ,-16748 ,-16740 ,-16762 ,-16949 ,-17080 ,-17097 ,-17054 ,-17003 ,-16960 ,-16929 ,-16947 ,-16964 ,-16946 ,-16913 ,-16872 ,-16844 ,-16822 ,-16805 ,-16792 ,-16824 ,-17006 ,-17142 ,-17165 ,-17121 ,-17074 ,-17032 ,-17015 ,-17021 ,-17030 ,-17022 ,-16967 ,-16927 ,-16893 ,-16864 ,-16846 ,-16839 ,-16828 ,-16919 ,-17115 ,-17217 ,-17214 ,-17163 ,-17099 ,-17052]
//
//    var tempBufferR : [Int32] = [3221 ,3436 ,3539 ,3540 ,3548 ,3613 ,3690 ,3756 ,3814 ,3866 ,3910 ,3764 ,3089 ,2566 ,2759 ,3199 ,3440 ,3610 ,3650 ,3636 ,3662 ,3699 ,3713 ,3763 ,3807 ,3821 ,3635 ,2591 ,1971 ,2103 ,2517 ,2949 ,98 ,46 ,66 ,161 ,277 ,375 ,427 ,472 ,497 ,531 ,394 ,-83 ,-359 ,-347 ,-221 ,-73 ,52 ,45 ,-35 ,-69 ,7 ,127 ,250 ,344 ,410 ,461 ,382 ,-134 ,-520 ,-582 ,-441 ,-328 ,-196 ,-130 ,-179 ,-207 ,-149 ,-47 ,72 ,171 ,242 ,297 ,326, 213 ,-326 ,-712 ,-769 ,-642 ,-514 ,-381 ,-330 ,-384 ,-415 ,-345 ,-222 ,-98 ,16 ,70 ,122 ,141 ,163 ,-92 ,-655 ,-959 ,-938 ,-773 ,-582 ,-413]
    
//    var tempBufferIR : [Int32] = [126600 ,126947 ,127440 ,127865 ,127245 ,126049 ,125055 ,124551 ,124851 ,125375 ,125870 ,126073 ,126036 ,126022 ,126100 ,126327 ,126661 ,127011 ,127351 ,127665 ,127202 ,126045 ,124953 ,124478 ,124839 ,125426 ,125972 ,126163 ,126115 ,126055 ,126070 ,126243 ,127100 ,127248 ,126380 ,125145 ,124163 ,124201 ,124690 ,125304 ,125719 ,125807 ,125742 ,125741 ,125913 ,126252 ,126723 ,127260 ,127648 ,126931 ,125722 ,124557 ,124169 ,124470 ,124984 ,125553 ,125848 ,125823 ,125651 ,125567 ,125632 ,125874 ,126204 ,126534 ,126043 ,124721 ,123597 ,123594 ,124006 ,124487 ,124876 ,125016 ,124970 ,124935 ,125049 ,125319 ,125680 ,126065 ,126407 ,125969 ,124519 ,123274 ,123218 ,123608 ,124089 ,124542 ,124740 ,124751 ,124721 ,124828 ,125034 ,125311 ,125657 ,126009 ,125831 ,124559 ,123107 ,122853 ,123233 ,123696 ,124099 ,124338 ,124324 ,124327 ,124427 ,124679 ,124996 ,125348 ,125685 ,125823 ,124883 ,123309 ,122656 ,122912 ,123433 ,123954 ,124268 ,124293 ,124203 ,124205 ,124386 ,124675 ,125057 ,125398 ,125652 ,124995 ,123462 ,122543 ,122717 ,123266 ,123824 ,124209 ,124248 ,124147 ,124181 ,124382 ,124704 ,125060 ,125418 ,125705 ,125032 ,123498 ,122598 ,122777 ,123274 ,123814 ,124224 ,124347 ,124297 ,124299 ,20945]
//
//    var tempBufferR : [Int32] = [80682 ,99871 ,99956 ,100035 ,100057 ,99691 ,99351 ,99222 ,99219 ,99355 ,99529 ,99654 ,99676 ,99670 ,99708 ,99768 ,99844 ,99944 ,100030 ,99857 ,99417 ,99190 ,99132 ,99146 ,99281 ,99428 ,99488 ,99492 ,99500 ,99562 ,99643 ,99746 ,98860 ,98946 ,99040 ,99129 ,99205 ,99260 ,99064 ,98694 ,98368 ,98341 ,98494 ,98648 ,98769 ,98807 ,98789 ,98791 ,98822 ,98897 ,98982 ,99080 ,99151 ,99223 ,99206 ,98880 ,98509 ,98323 ,98438 ,98627 ,98798 ,98878 ,98865 ,98822 ,98803 ,98816 ,98890 ,98963 ,99061 ,99164 ,99259 ,99149 ,98820 ,98478 ,98390 ,98499 ,98643 ,98794 ,98850 ,98843 ,98827 ,98856 ,98919 ,99013 ,99115 ,99216 ,99291 ,99354 ,99152 ,98798 ,98487 ,98455 ,98565 ,98729 ,98857 ,98904 ,98884 ,98862 ,98894 ,98954 ,99062 ,99166 ,99243 ,99327 ,99346 ,99058 ,98698 ,98458 ,98492 ,98633 ,98805 ,98911 ,98917 ,98896 ,98894 ,98937 ,99024 ,99139 ,99220 ,99311 ,99389 ,99285 ,98939 ,98614 ,98495 ,98610 ,98776 ,98933 ,99014 ,99024 ,99007 ,99032 ,99096 ,99184 ,99272 ,99366 ,99445 ,99459 ,99159 ,98810 ,98566 ,98593 ,98733 ,98895 ,99003 ,99011 ,98984 ,98978 ,99026 ,99088]
    
//    var tempBufferIR : [Int32] = [140282 ,140283 ,140258 ,140285 ,140364 ,140383 ,140431 ,140467 ,140438 ,140411 ,140419 ,140441 ,140317 ,140039 ,140023 ,140108 ,140076 ,140057 ,140055 ,140044 ,140032 ,140110 ,140177 ,140178 ,140167 ,140180 ,140173 ,140208 ,140256 ,140279 ,140300 ,140248 ,139956 ,139586 ,139559 ,139643 ,139641 ,139611 ,139656 ,139674 ,139720 ,139804 ,139856 ,139929 ,139969 ,139977 ,139955 ,139972 ,139963 ,140041 ,140085 ,140153 ,140118 ,139815 ,139684 ,139755 ,139769 ,139789 ,139874 ,139969 ,140042 ,140101 ,140175 ,140216 ,140259 ,140328 ,140352 ,140389 ,140416 ,140468 ,140506 ,140549 ,140523 ,140267 ,140185 ,140218 ,140250 ,140223 ,140223 ,140280 ,140317 ,140367 ,140443 ,140498 ,140518 ,140525 ,140547 ,140581 ,140573 ,140617 ,140688 ,140641 ,140430 ,140343 ,140390 ,140451 ,140443 ,140493 ,140543 ,140515 ,140572 ,140614 ,140643 ,140658 ,140724 ,140709 ,140714 ,140774 ,140825 ,140688 ,140492 ,140503 ,140536 ,140551 ,140593 ,140644 ,140614 ,140655]
//
//    var tempBufferR : [Int32] = [120724 ,120745 ,120762 ,120766 ,120785 ,120798 ,120811 ,120830 ,120841 ,120838 ,120860 ,120874 ,120791 ,120708 ,120721 ,120746 ,120732 ,120742 ,120765 ,120763 ,120791 ,120808 ,120818 ,120836 ,120828 ,120814 ,120820 ,120840 ,120885 ,120920 ,120925 ,120942 ,120942 ,120906 ,120787 ,120759 ,120776 ,120781 ,120768 ,120781 ,120788 ,120803 ,120793 ,120803 ,120793 ,120791 ,120822 ,120823 ,120834 ,120842 ,120858 ,120859 ,120858 ,120876 ,120895 ,120865 ,120752 ,120706 ,120733 ,120737 ,120731 ,120738 ,120738 ,120694 ,120694 ,120726 ,120724 ,120757 ,120776 ,120785 ,120788 ,120805 ,120807 ,120825 ,120843 ,120853 ,120772 ,120661 ,120675 ,120702 ,120703 ,120718 ,120724 ,120739 ,120759 ,120754 ,120775 ,120791 ,120779 ,120772 ,120791 ,120809 ,120835 ,120873 ,120862 ,120785 ,120708 ,120711 ,120711 ,120706 ,120727 ,120737 ,120729 ,120747 ,120760 ,120789 ,120804 ,120821 ,120826 ,120829 ,120856 ,120856 ,120787 ,120731 ,120754 ,120762 ,120748 ,120741]
    
    
    var spo2Data: Int32 = 0
    var spo2Valid: Int8 = 0
    var heartrateData: Int32 = 0
    var heartrateValid: Int8 = 0
    
    //Identifier Flags
    var readyToRecord = false
    var isPPG = false //true - PPG; False - ECG
    var isHRB = false //true - heartbeat data
    var isOXG = false // true - oxygen level data
    
    //Array Flags
    var redIsFull = false
    var irIsFull = false
    
    //Line Chart Variables
    var lineChartEntry_ECG  = [ChartDataEntry]()
    var lineChartEntry_PPGRED  = [ChartDataEntry]()
    var lineChartEntry_PPGIR  = [ChartDataEntry]()
    var XValueData: Double = 0.0
    
    var manager:CBCentralManager!
    var peripheral:CBPeripheral!
    
    //UUID and service name
    let BEAN_NAME = "HMSoft"
    let BEAN_CHARACTERISTIC_UUID =
        CBUUID(string: "FFE1")
    let BEAN_SERVICE_UUID =
        CBUUID(string: "FFE0")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Instantiate manager
//        var pointerPPG = UnsafeMutablePointer<Int32>(ppgBuffer);
        
        //Initialize Memory
//        let ppgRedPointer: UnsafeMutablePointer<Int32> = UnsafeMutablePointer(mutating: ppgRedBuffer).withMemoryRebound(to: UnsafeMutablePointer<Int32>.self, capacity: 100){
//            $0.pointee
//        }
//
//        let ppgIrPointer: UnsafeMutablePointer<Int32> = UnsafeMutablePointer(mutating: ppgRedBuffer).withMemoryRebound(to: UnsafeMutablePointer<Int32>.self, capacity: 1){
//            $0.pointee
//        }
        
//        let uint8Pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: 64)
//        uint8Pointer.initialize(to: 0, count: 64)

//        maxim_heart_rate_and_oxygen_saturation(&tempBufferIR, Int32(tempBufferIR.count), &tempBufferR, &spo2Data, &spo2Valid, &heartrateData, &heartrateValid)
//        print("spo2 valid = ", spo2Valid)
//        print(spo2Data)
//        print("heartrate valid = ", heartrateValid)
//        print(heartrateData)
   
        

    }
    //identifier = 1: ECG; =2: PPG
    func updateGraph(YValueData: Double, identifier: Int){
        XValueData = XValueData + 1
        let value = ChartDataEntry(x: XValueData, y: YValueData)
        
        //For ECG Data
        if identifier == 1 {
            //Limit data points in a graph
            if lineChartEntry_ECG.count == 500 {
                lineChartEntry_ECG.remove(at: 0)
                lineChartEntry_ECG.append(value)
            }
            else {
                lineChartEntry_ECG.append(value)
            }
            
            let lineECG = LineChartDataSet(values: lineChartEntry_ECG, label: "Number")
            lineECG.colors = [UIColor(red: 11/255, green: 144/255, blue: 137/255, alpha: 1)]
            lineECG.drawCirclesEnabled = false
            lineECG.lineWidth = 3

            let data = LineChartData() //This is the object that will be added to the chart
            data.addDataSet(lineECG) //Adds the line to the dataSet
            data.setDrawValues(false)
            
            lineChartView_ECG.data = data
            lineChartView_ECG.xAxis.labelPosition = .bottom
            lineChartView_ECG.xAxis.drawGridLinesEnabled = false
            lineChartView_ECG.rightAxis.enabled = false
            lineChartView_ECG.legend.enabled = false
         
        }
        else if identifier == 2 || identifier == 3{
            if identifier == 2 {
                if lineChartEntry_PPGRED.count == 20 {
                    lineChartEntry_PPGRED.remove(at: 0)
                    lineChartEntry_PPGRED.append(value)
                }
                else {
                    lineChartEntry_PPGRED.append(value)
                }
            }
            else if identifier == 3 {
                if lineChartEntry_PPGIR.count == 20 {
                    lineChartEntry_PPGIR.remove(at: 0)
                    lineChartEntry_PPGIR.append(value)
                }
                else {
                    lineChartEntry_PPGIR.append(value)
                }
            }
            
            let linePPGRED = LineChartDataSet(values: lineChartEntry_PPGRED, label: "PPG RED")
            linePPGRED.colors = [NSUIColor.blue] //Sets the colour to blue
            linePPGRED.drawCirclesEnabled = false
            
            let linePPGIR = LineChartDataSet(values: lineChartEntry_PPGIR, label: "PPG IR")
            linePPGRED.colors = [NSUIColor.red] //Sets the colour to blue
            linePPGRED.drawCirclesEnabled = false
            
            var dataSets = [LineChartDataSet]()
            dataSets.append(linePPGRED)
            dataSets.append(linePPGIR)
            
            let data = LineChartData() //This is the object that will be added to the chart
            data.addDataSet(linePPGRED) //Adds the line to the dataSet
            data.addDataSet(linePPGIR) //Adds the line to the dataSet
            data.setDrawValues(false)
            
            lineChartView_PPG.data = data
            lineChartView_PPG.xAxis.labelPosition = .bottom
            
        }
    }
    
    /////////////////////////
    ///////BLE Functions/////
    /////////////////////////
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        manager = CBCentralManager(delegate: self, queue: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Scan for devices
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            //            _ = Timer.scheduledTimer(timeInterval: TimeInterval, target: self, selector: #selector(pauseScan), userInfo: nil, repeats: false)
            manager.scanForPeripherals(withServices: nil, options: nil)
        case .poweredOff:
            print( "Bluetooth on this device is currently powered off.")
        case .unsupported:
            print( "This device does not support Bluetooth Low Energy.")
        case .unauthorized:
            print( "This app is not authorized to use Bluetooth Low Energy.")
        case .resetting:
            print( "The BLE Manager is resetting; a state update is pending.")
        case .unknown:
            print( "The state of the BLE Manager is unknown.")
            
        }
        //        if central.state == CBManagerState.poweredOn{
        //            central.scanForPeripherals(withServices: nil, options: nil)
        //        } else {
        //            print("Bluetooth not avaliable.")
        //        }
    }
    //Connect to a devic
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let device = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey) as? NSString
        print(device ?? "null")
        if device?.contains(BEAN_NAME) == true {
            print("*** PAUSING SCAN...")
            self.manager.stopScan()
            
            self.peripheral = peripheral
            self.peripheral.delegate = self
            
            manager.connect(peripheral, options: nil)
        }
    }
    
    //Get services
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }
    
    
    
    //Get Characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services!{  
            let thisService = service as CBService
            print(service.uuid)
            if service.uuid == BEAN_SERVICE_UUID{
                peripheral.discoverCharacteristics(nil, for: thisService)
            }
        }
    }
    
    //setup notification
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            //            var parameter = NSInteger(1)
            //            let data = NSData(bytes: &parameter, length: 1) as Data
            
            let thisCharacteristic = characteristic as CBCharacteristic
            print(thisCharacteristic.uuid)
            if thisCharacteristic.uuid == BEAN_CHARACTERISTIC_UUID {
                //Set notification
                self.peripheral.setNotifyValue(true, for: thisCharacteristic)
                
                //Write Value
                //                print("send 1")
                //                peripheral.writeValue(data, for: characteristic, type: .withResponse)
            }
        }
    }
    
    //Receive changes
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        //        var count:UInt32 = 0;
        let data = characteristic.value
        //var values = [UInt8](data!)
        let BLEValueString: String = String(data:data!, encoding: .utf8)!
        let BLEInt32:Int32? = Int32(BLEValueString)
//        let BLEInt32: Int32 = data!.withUnsafeBytes {
//            (pointer: UnsafePointer<Int32>) -> Int32? in
//            if MemoryLayout<Int32>.size != data?.count { return 0 }
//            return pointer.pointee
//            }!
        //var BLEValueDouble: Double = 0.0
        
        if characteristic.uuid == BEAN_CHARACTERISTIC_UUID {
            print(BLEValueString)
//            print(BLEInt32)
            if BLEValueString.hasPrefix("ECG"){
                currentState = .ECG
                return
            }
            else if BLEValueString.hasPrefix("PPGRED"){
                currentState = .PPGRED
                return
            }
            else if BLEValueString.hasPrefix("PPGIR"){
                currentState = .PPGIR
                return
            }
            else if BLEValueString.hasPrefix("HRB"){
                currentState = .HRB
                return
            }
            else if BLEValueString.hasPrefix("OXG"){
                currentState = .OXG
                return
            }
            else if BLEValueString.hasPrefix("TEMP"){
                currentState = .TEMP
                return
            }
            else if BLEValueString.hasPrefix("EHRB"){
                currentState = .ECGHRB
                return
            }
            else {
                if (currentState == .Waiting) {
                    return
                }
            }
            
            switch (currentState){
            case .Waiting:
                print("error")
            case .ECG:
                updateGraph(YValueData: Double(BLEValueString)!, identifier: 1)
            case .PPGRED:
                ppgRedBuffer.append(BLEInt32!)
                if ppgRedBuffer.count == 150 {
                    redIsFull = true
                    if irIsFull {
                        maxim_heart_rate_and_oxygen_saturation(&ppgIrBuffer, Int32(ppgIrBuffer.count), &ppgRedBuffer, &spo2Data, &spo2Valid, &heartrateData, &heartrateValid)
                        print("spo2 valid = ", spo2Valid)
                        print(spo2Data)
                        print("heartrate valid = ", heartrateValid)
                        print(heartrateData)
                        redIsFull = false
                        irIsFull = false
                        ppgRedBuffer.removeAll()
                        ppgIrBuffer.removeAll()
                    }
                }
                updateGraph(YValueData: Double(BLEValueString)!, identifier: 2)
            case .PPGIR:
                ppgIrBuffer.append(BLEInt32!)
                if ppgIrBuffer.count == 150{
                    irIsFull = true
                    if redIsFull {
                        for element in ppgIrBuffer {
                            print("ir", element)
                        }
                        for element1 in ppgRedBuffer {
                            print("red", element1)
                        }
                        maxim_heart_rate_and_oxygen_saturation(&ppgIrBuffer, Int32(ppgIrBuffer.count), &ppgRedBuffer, &spo2Data, &spo2Valid, &heartrateData, &heartrateValid)
//                        print("spo2 valid = ", spo2Valid)
//                        print(spo2Data)
//                        print("heartrate valid = ", heartrateValid)
//                        print(heartrateData)
                        redIsFull = false
                        irIsFull = false
                        ppgRedBuffer.removeAll()
                        ppgIrBuffer.removeAll()
                    }
//                    for element in ppgIrBuffer {
//                        print("ir", element)
//                    }
                    
                }
                
                
                updateGraph(YValueData: Double(BLEValueString)!, identifier: 3)
            case .HRB:
                hrbTxt.text = BLEValueString
            case .OXG:
                oxgTxt.text = BLEValueString
            case .TEMP:
                tempTxt.text = BLEValueString
            case .ECGHRB:
                ecgHRBTxt.text = BLEValueString
            }
            
//
//
//            if BLEValueString.hasPrefix("ECG"){
//                isPPG = false
//                readyToRecord = true
//            }
//            else if BLEValueString.hasPrefix("PPGRED"){
//                isPPG = true
//                readyToRecord = true
//            }
//            else if BLEValueString.hasPrefix("HRB"){
//                hrbTxt.text = BLEValueString
//            }
//            else if !isPPG && readyToRecord {
//                updateGraph(YValueData: Double(BLEValueString)!, identifier: 1)
//            }
//            else if isPPG && readyToRecord {
//                //Update Value
//                updateGraph(YValueData: Double(BLEValueString)!, identifier: 2)
//            }
//            else if isHRB {
//
//            }
            
            
            //String
            //print(String(data:data!, encoding: .utf8) ?? "null")
            //Integer
            //print(values[0])
        }
    }
    
    //Disconnect and try again
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        central.scanForPeripherals(withServices: nil, options: nil)
    }
    
    
}


enum CurrentState {
    case Waiting
    case ECG
    case PPGRED
    case PPGIR
    case HRB
    case OXG
    case TEMP
    case ECGHRB
}













