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
    

    @IBOutlet var lineChartView_ECG: LineChartView!
    @IBOutlet var lineChartView_PPG: LineChartView!
    
    //Line Chart Variables
    var lineChartEntry_ECG  = [ChartDataEntry]()
    var lineChartEntry_PPG  = [ChartDataEntry]()
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
        
        
    }
    //identifier = 1: ECG; =2: PPG
    func updateGraph(YValueData: Double, identifier: Int){
        XValueData = XValueData + 100
        let value = ChartDataEntry(x: XValueData, y: YValueData)
        
        //For ECG Data
        if identifier == 1 {
            if lineChartEntry_ECG.count == 5 {
                lineChartEntry_ECG.remove(at: 0)
                lineChartEntry_ECG.append(value)
            }
            else {
                lineChartEntry_ECG.append(value)
            }
            
            let line1 = LineChartDataSet(values: lineChartEntry_ECG, label: "Number")
            line1.colors = ChartColorTemplates.colorful()
            line1.drawCirclesEnabled = false
            let data = LineChartData() //This is the object that will be added to the chart
            data.addDataSet(line1) //Adds the line to the dataSet
            lineChartView_ECG.data = data
            
        }
        else if identifier == 2 {
            lineChartEntry_PPG.append(value)
            let line2 = LineChartDataSet(values: lineChartEntry_PPG, label: "Number")
            line2.colors = [NSUIColor.blue] //Sets the colour to blue
            let data = LineChartData() //This is the object that will be added to the chart
            data.addDataSet(line2) //Adds the line to the dataSet
            lineChartView_PPG.data = data
            
        }
        
    }
    
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
        var BLEValueDouble: Double = 0.0
        
        if characteristic.uuid == BEAN_CHARACTERISTIC_UUID {
            print(BLEValueString)
            if BLEValueString.hasPrefix("ECG"){
                //Convert String to Double as update graph needed
                BLEValueDouble = (BLEValueString.replacingOccurrences(of: "ECG", with: "") as NSString).doubleValue
                //Update Value
                updateGraph(YValueData: BLEValueDouble, identifier: 1)
            }
            else if BLEValueString.hasPrefix("PPG"){
                //Convert String to Double as update graph needed
                BLEValueDouble = (BLEValueString.replacingOccurrences(of: "PPG", with: "") as NSString).doubleValue
                //Update Value
                updateGraph(YValueData: BLEValueDouble, identifier: 2)
            }
            
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


















