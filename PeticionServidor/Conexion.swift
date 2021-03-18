//
//  Conexion.swift
//  PeticionServidor
//
//

import Foundation

class Conexion {
    var url: String="https://qh6ol1kw41.execute-api.us-east-1.amazonaws.com/prod/frontal/"
    var imagen: String =  "no declarada"
    var contador:Int = 0
    var limite:Int = 3
    var selfie:Bool=false
    var respuesta:String=""
    var faceID:String=""
    
    func getRespuesta()->String{
        return respuesta
    }
    func getURL() -> String{
        return url;
    }
    func setURL(nueva:String){
        url=nueva
    }
    
    func getImagen()->String{
        return imagen
    }
    
    func setImagen(nuevaImagen:String){
        imagen=nuevaImagen
    }
    
    func getContador()->Int{
        return contador
    }
    
    func incrementar(){
        contador=contador+1
    }
    func getLimite()->Int{
        return limite
    }
    
    func modificarLimite(nuevoLimite:Int){
        limite=nuevoLimite
    }
    
    func tipoSelfie(){
        selfie=true
    }
    func tipoOtro(){
        selfie=false
    }
    
    func esSelfie()->Bool{
        return selfie
    }
    
    func setFaceId(nuevoFaceid:String){
        faceID=nuevoFaceid
    }
    func getFaceId()->String{
        return faceID
    }
    
    func crearConexion(completion: @escaping ((String) -> Void)){
        let Url = String(format: url)
        let serviceUrl = URL(string: Url)!
        let enviar = "data:image/png;base64,"+imagen
        let parameters: [String: Any];
        if(selfie){
            parameters = ["FACE_ID":faceID,"img": enviar]
        }else{
            parameters = ["img": enviar]
        }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: .fragmentsAllowed)
        request.httpBody = httpBody
    
        request.timeoutInterval = 2000
        //request.timeoutInterval = 200
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
          // this is where the completion handler code goes
          if let response = response {
            print(response)
          }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                    print("codigo de servidor \(httpStatus.statusCode)")
                completion("codigo de servidor \(httpStatus.statusCode)")
                /*if(httpStatus.statusCode==220){
                    self.crearConexion(completion: <#T##((String) -> Void)##((String) -> Void)##(String) -> Void#>)
                }*/
            }
            else if let data = data {
                print(data)
                do {
                    let json:String = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! String
                    print("repuesta")
                    print(json)
                    self.respuesta=json
                    completion(json)
                } catch let error as NSError {
                    print("Error")
                    print(error)
                    self.respuesta="Error"
                    completion(error as! String)
                }
            }else{
                print("No hay respuesta")
                self.respuesta="Time out"
                completion("Time out")
            }
        }.resume()
    }
    
}
