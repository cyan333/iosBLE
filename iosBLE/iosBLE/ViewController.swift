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
    
    var ppgRedBuffer = [String]()
    var ppgIrBuffer =  [String]()
//    var tempBuffer : [Int32] = [-3734,-3577,-3505,-3458,-3354,-3347,-4012,-4978,-5414,-5311,-5080,-4891,-4691,-4638,-4676,-4662,-4505,-4270,-4059,-3867,-3703,-3616,-3545,-3439,-3370,-3466,-4395,-5321,-5537,-5349,-5166,-5017,-3427,-3341,-3258,-3199,-3155,-3143,-3112,-3095,-3073,-3332,-3955,-4105,-3863,-3642,-3507,-3408,-3400,-3395,-3349,-3292,-3215,-3163,-3135,-3131,-3112,-3085,-3086,-3405,-4103,-4275,-4095,-3883,-3740,-3637,-3613,-3649,-3621,-3520,-3430,-3362,-3311,-3283,-3263,-3242,-3213,-3257,-3910,-4485,-4508,-4296,-4097,-3951,-3861,-3893,-3930,-3879,-3753,-3631,-3547,-3490,-3455,-3465,-3420,-3363,-3323,-3279,-3421,-4298]
//
//    var tempBufferR : [Int32] = [-16654,-16594,-16570,-16550,-16508,-16495,-16736,-17110,-17271,-17244,-17151,-17091,-17007,-16986,-17011,-17000,-16942,-16856,-16769,-16692,-16633,-16599,-16568,-16526,-16503,-16534,-16874,-17223,-17304,-17244,-17176,-17120,-17120,-17096,-17075,-17053,-17037,-17043,-17034,-17025,-17022,-17118,-17316,-17369,-17282,-17215,-17175,-17135,-17144,-17143,-17133,-17125,-17094,-17076,-17073,-17073,-17063,-17060,-17058,-17167,-17409,-17464,-17402,-17326,-17277,-17246,-17238,-17246,-17244,-17212,-17188,-17167,-17153,-17145,-17146,-17132,-17125,-17143,-17355,-17550,-17561,-17488,-17415,-17363,-17341,-17345,-17358,-17348,-17310,-17274,-17244,-17219,-17218,-17216,-17197,-17191,-17169,-17160,-17199,-17496]
    
    var tempBuffer : [Int32] = [-13475 ,-13389 ,-13355 ,-13354 ,-13335 ,-13326 ,-13308 ,-13286 ,-13267 ,-13250 ,-13243 ,-13292 ,-13552 ,-13741 ,-13662 ,-13499 ,-13415 ,-13354 ,-13333 ,-13330 ,-13321 ,-13321 ,-13319 ,-13307 ,-13299 ,-13294 ,-13371 ,-13755 ,-13989 ,-13941 ,-13770 ,-13621 ,-16838 ,-16878 ,-16871 ,-16841 ,-16803 ,-16773 ,-16746 ,-16730 ,-16718 ,-16701 ,-16764 ,-16929 ,-17026 ,-17019 ,-16966 ,-16917 ,-16872 ,-16879 ,-16902 ,-16915 ,-16893 ,-16846 ,-16796 ,-16780 ,-16748 ,-16740 ,-16762 ,-16949 ,-17080 ,-17097 ,-17054 ,-17003 ,-16960 ,-16929 ,-16947 ,-16964 ,-16946 ,-16913 ,-16872 ,-16844 ,-16822 ,-16805 ,-16792 ,-16824 ,-17006 ,-17142 ,-17165 ,-17121 ,-17074 ,-17032 ,-17015 ,-17021 ,-17030 ,-17022 ,-16967 ,-16927 ,-16893 ,-16864 ,-16846 ,-16839 ,-16828 ,-16919 ,-17115 ,-17217 ,-17214 ,-17163 ,-17099 ,-17052]

    var tempBufferR : [Int32] = [3221 ,3436 ,3539 ,3540 ,3548 ,3613 ,3690 ,3756 ,3814 ,3866 ,3910 ,3764 ,3089 ,2566 ,2759 ,3199 ,3440 ,3610 ,3650 ,3636 ,3662 ,3699 ,3713 ,3763 ,3807 ,3821 ,3635 ,2591 ,1971 ,2103 ,2517 ,2949 ,98 ,46 ,66 ,161 ,277 ,375 ,427 ,472 ,497 ,531 ,394 ,-83 ,-359 ,-347 ,-221 ,-73 ,52 ,45 ,-35 ,-69 ,7 ,127 ,250 ,344 ,410 ,461 ,382 ,-134 ,-520 ,-582 ,-441 ,-328 ,-196 ,-130 ,-179 ,-207 ,-149 ,-47 ,72 ,171 ,242 ,297 ,326, 213 ,-326 ,-712 ,-769 ,-642 ,-514 ,-381 ,-330 ,-384 ,-415 ,-345 ,-222 ,-98 ,16 ,70 ,122 ,141 ,163 ,-92 ,-655 ,-959 ,-938 ,-773 ,-582 ,-413]
    
    var spo2Data: Int32 = 0
    var spo2Valid: Int8 = 0
    var heartrateData: Int32 = 0
    var heartrateValid: Int8 = 0
    
    //Identifier Flags
    var readyToRecord = false
    var isPPG = false //true - PPG; False - ECG
    var isHRB = false //true - heartbeat data
    var isOXG = false // true - oxygen level data
    
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
        let ppgRedPointer: UnsafeMutablePointer<Int32> = UnsafeMutablePointer(mutating: ppgRedBuffer).withMemoryRebound(to: UnsafeMutablePointer<Int32>.self, capacity: 100){
            $0.pointee
        }
        
        let ppgIrPointer: UnsafeMutablePointer<Int32> = UnsafeMutablePointer(mutating: ppgRedBuffer).withMemoryRebound(to: UnsafeMutablePointer<Int32>.self, capacity: 1){
            $0.pointee
        }
        
        let uint8Pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: 64)
        uint8Pointer.initialize(to: 0, count: 64)

        maxim_heart_rate_and_oxygen_saturation(&tempBuffer, Int32(tempBuffer.count), &tempBufferR, &spo2Data, &spo2Valid, &heartrateData, &heartrateValid)
        print("spo2 valid = ", spo2Valid)
        print(spo2Data)
        print("heartrate valid = ", heartrateValid)
        print(heartrateData)
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
        //var BLEValueDouble: Double = 0.0
        
        if characteristic.uuid == BEAN_CHARACTERISTIC_UUID {
            print(BLEValueString)
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
                if ppgRedBuffer.count == 20{
                    for element in ppgRedBuffer {
                        print("hi", element)
                    }
                    ppgRedBuffer.removeAll()
                }
                ppgRedBuffer.append(BLEValueString)
                
                updateGraph(YValueData: Double(BLEValueString)!, identifier: 2)
            case .PPGIR:
                
                if ppgIrBuffer.count == 20{
                    for element in ppgIrBuffer {
                        print("hi", element)
                    }
                    ppgIrBuffer.removeAll()
                }
                ppgIrBuffer.append(BLEValueString)
                
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













