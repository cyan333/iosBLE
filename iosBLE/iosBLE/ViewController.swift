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


    
    
    var ppgbuffer : [[Int32]] = [[]];

    var spo2Data: Int32 = 0
    var spo2Valid: Int8 = 0
    var heartrateData: Int32 = 0
    var heartrateValid: Int8 = 0
    var ECG_heartrate: Int32 = 0
    var ecgBuffer =  [Int32]()
    
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
    
    //Database Flag
    var sendingData = false
    
    
    var manager:CBCentralManager!
    var peripheral:CBPeripheral!
    
    //UUID and service name
    let BEAN_NAME = "HMSoft"
    let BEAN_CHARACTERISTIC_UUID = CBUUID(string: "FFE1")
    let BEAN_SERVICE_UUID = CBUUID(string: "FFE0")
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        var a: Float = 25
//        a += 0.00

//        WebService.sendData(ehr: 20, phr: 34, temp: 25.8, spo2: 88, ppgList: self.ppgbbb, ecgList: self.tempBufferR) { (error) in
//        print(error);
//        }
        _ = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(sayHello), userInfo: nil, repeats: true)
        
        
    }
    
    @objc func sayHello()
    {
        let tempBufferR : [Int32] = [120724 ,120745 ,120762 ,120766 ,120785 ,120798 ,120811 ,120830 ,120841 ,120838 ,120860 ,120874 ,120791 ,120708 ,120721 ,120746 ,120732 ,120742 ,120765 ,120763 ,120791 ,120808 ,120818 ,120836 ,120828 ,120814 ,120820 ,120840 ,120885 ,120920 ,120925 ,120942 ,120942 ,120906 ,120787 ,120759 ,120776 ,120781 ,120768 ,120781 ,120788 ,120803 ,120793 ,120803 ,120793 ,120791 ,120822 ,120823 ,120834 ,120842 ,120858 ,120859 ,120858 ,120876 ,120895 ,120865 ,120752 ,120706 ,120733 ,120737 ,120731 ,120738 ,120738 ,120694 ,120694 ,120726 ,120724 ,120757 ,120776 ,120785 ,120788 ,120805 ,120807 ,120825 ,120843 ,120853 ,120772 ,120661 ,120675 ,120702 ,120703 ,120718 ,120724 ,120739 ,120759 ,120754 ,120775 ,120791 ,120779 ,120772 ,120791 ,120809 ,120835 ,120873 ,120862 ,120785 ,120708 ,120711 ,120711 ,120706 ,120727 ,120737 ,120729 ,120747 ,120760 ,120789 ,120804 ,120821 ,120826 ,120829 ,120856 ,120856 ,120787 ,120731 ,120754 ,120762 ,120748 ,120741]
        
        let ppgbbb: [[Int32]] = [[120724,140282],[120724,140282]]
            print("start sending======================================")
            WebService.sendData(ehr: 20, phr: 34, temp: 25.8, spo2: 88, ppgList: ppgbbb, ecgList: tempBufferR) { (error) in
                if error == "" {
                    print("send to database======================================")
                }
                else {
                    print(error);
                }
            }
    }
    
    //identifier = 1: ECG; =2: PPG
    func updateGraph(YValueData: Double, identifier: Int){
        XValueData = XValueData + 1
        let value = ChartDataEntry(x: XValueData, y: YValueData)
        
        //For ECG Data
        if identifier == 1 {
            //Limit data points in a graph
            if lineChartEntry_ECG.count == 300 {
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
                if lineChartEntry_PPGRED.count == 100 {
                    lineChartEntry_PPGRED.remove(at: 0)
                    lineChartEntry_PPGRED.append(value)
                }
                else {
                    lineChartEntry_PPGRED.append(value)
                }
            }
            else if identifier == 3 {
                if lineChartEntry_PPGIR.count == 150 {
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
        print("get service")
        peripheral.discoverServices(nil)
    }
    
    
    
    //Get Characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services!{  
            let thisService = service as CBService
            print(service.uuid)
            if service.uuid == BEAN_SERVICE_UUID{
                print("get Char")
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
        
        print("111111111111")
        if characteristic.uuid == BEAN_CHARACTERISTIC_UUID {
            
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
                ecgBuffer.append(BLEInt32!)

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
//                        ppgRedBuffer.removeAll()
//                        ppgIrBuffer.removeAll()
                    }
                }
                updateGraph(YValueData: Double(BLEValueString)!, identifier: 2)
            case .PPGIR:
                ppgIrBuffer.append(BLEInt32!)
                if ppgIrBuffer.count == 150{
                    irIsFull = true
                    if redIsFull {
//                        for element in ppgIrBuffer {
//                            print("ir", element)
//                        }
//                        for element1 in ppgRedBuffer {
//                            print("red", element1)
//                        }
                        maxim_heart_rate_and_oxygen_saturation(&ppgIrBuffer, Int32(ppgIrBuffer.count), &ppgRedBuffer, &spo2Data, &spo2Valid, &heartrateData, &heartrateValid)
                        print("spo2 valid = ", spo2Valid)
                        print(spo2Data)
                        print("heartrate valid = ", heartrateValid)
                        print(heartrateData)
                        redIsFull = false
                        irIsFull = false
//                        ppgRedBuffer.removeAll()
//                        ppgIrBuffer.removeAll()
                    }
//                    for element in ppgIrBuffer {
//                        print("ir", element)
//                    }

                }


//                updateGraph(YValueData: Double(BLEValueString)!, identifier: 3)
            case .HRB:
                hrbTxt.text = String (heartrateData)
            case .OXG:
                oxgTxt.text = String(Int(spo2Data))
            case .ECGHRB:
                ECG_heartrate = BLEInt32!
                ecgHRBTxt.text = BLEValueString
            case .TEMP:
//                TEMP = BLEInt32!

                tempTxt.text = BLEValueString

                //if first array is empty, remove all, continute
                if (ecgBuffer.count == 0){
                    ecgBuffer.removeAll()
                    ppgIrBuffer.removeAll()
                    ppgRedBuffer.removeAll()
                    break
                }

                for i in 0...149 {
                    var tempBuffer =  [Int32]()
//                    tempBuffer += [ppgRedBuffer[i], ppgIrBuffer[i]]
                    tempBuffer.append(ppgRedBuffer[i])
                    tempBuffer.append(ppgIrBuffer[i])
                    ppgbuffer.append(tempBuffer)
                }

                if(sendingData == false){
                    sendingData = true
                    _ = ppgbuffer;
                    _ = ecgBuffer
                    var temperature = Float(BLEValueString)!
                    temperature += 0.01
                    let ECGhr = Int(ECG_heartrate)
                    _ = Int(heartrateData)
                    _ = Int(spo2Data)

//                    DispatchQueue.main.async {
//                        WebService.sendData(ehr: 20, phr: 34, temp: 25.8, spo2: 88, ppgList: self.ppgbbb, ecgList: self.tempBufferR) { (error) in
//                            print(error);
//                            self.sendingData = false
//                            self.ecgBuffer.removeAll()
//                            self.ppgIrBuffer.removeAll()
//                            self.ppgRedBuffer.removeAll()
//                        }
//                    }
                }


            }


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













