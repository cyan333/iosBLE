//
//  WebService.swift
//  iosBLE
//
//  Created by Fangming Ning on 2/11/18.
//  Copyright © 2018 fangming. All rights reserved.
//

import Foundation

open class WebService {
    open class func sendData(ehr: Int, phr: Int, temp: Double, spo2: Int, ppgList: [[Int]],
                             ecgList: [Int], completion: @escaping (_ error: String) -> Void) {
        do {
            var params = ["ehr": ehr, "phr": phr, "temp": temp, "spo2": spo2, "ppg": ppgList, "ecg": ecgList]
            let opt = try HTTP.POST("http://wc.fmning.com/save_ppgecg", parameters: params)
            opt.start{ response in
                if response.error != nil {
                    completion("The server is not running")
                    return
                }
                let dict = convertToDictionary(data: response.data)
                if dict!["error"] as! String != "" {
                    completion(dict!["error"]! as! String)
                }else{
                    completion("")
                }
            }
        } catch let error {
            print(error.localizedDescription)
            completion("The server is not running")
        }
    }
    
    open class func convertToDictionary(data: Data) -> [String: Any]? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
}
