//
//  ViewController.swift
//  PeticionServidor
//
//

import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var tituloAccion: UILabel!
    //Se declara explicitamente hasta que se pulce algun btn. es global y opcional
    var nuevaConexion = Conexion()
    var imagePicker: ImagePicker!

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        tituloAccion.text = "Prueba de OCR"
    }
    
    //IBOutlets definicion
    @IBOutlet weak var dataImage: UIImageView!
    

    @IBAction func tomarFrontal(_ sender: Any) {
        //Se asigna una nueva URL
        nuevaConexion.setURL(nueva: "https://d2qx3bqvr4h3ci.cloudfront.net/frontal/")
        nuevaConexion.tipoOtro()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker,animated: true,completion: nil)
        }else{
            print("No se pudo acceder a la camara")
        }
    }
    
    @IBAction func tomarTrasera(_ sender: Any) {
        //se asigna la nueva URL
        nuevaConexion.setURL(nueva: "https://d2qx3bqvr4h3ci.cloudfront.net/reverso/")
        nuevaConexion.tipoOtro()
        //Funcion para subir foto de carrete
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker,animated: true,completion: nil)
        }else{
            print("No se pudo acceder a la camara")
        }
    }
    
    
    @IBAction func tomarSelfie(_ sender: Any) {
        nuevaConexion.setURL(nueva: "https://d2qx3bqvr4h3ci.cloudfront.net/ine-selfie/")
        nuevaConexion.tipoSelfie()
        nuevaConexion.setFaceId(nuevoFaceid: "1231212313132")
        print("La url es \(nuevaConexion.getURL()) ")
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.cameraDevice = .front
            imagePicker.allowsEditing = true
            self.present(imagePicker,animated: true,completion: nil)
        }else{
            print("No se pudo acceder a la camara")
        }
    }
    
    
    @IBAction func tomarComprobante(_ sender: Any) {
        nuevaConexion.setURL(nueva: "https://d2qx3bqvr4h3ci.cloudfront.net/cfe/")
        nuevaConexion.tipoOtro()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker,animated: true,completion: nil)
        }else{
            print("No se pudo acceder a la camara")
        }
    }
    enum ConnectionResult {
       case success(Data)
       case failure(Error)
    }

    //Función del sistema para obtener la imagen capturada del uiimage
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            self.dataImage.image = pickedImage
            let _:NSData = pickedImage.pngData()! as NSData
            //Convertir a base64
            tituloAccion.text = "Procesando..."
            let strBase64 = ConvertImageToBase64String(img: pickedImage)
            nuevaConexion.setImagen(nuevaImagen: strBase64)
            nuevaConexion.crearConexion {
                salida in
                self.tituloAccion.text = salida
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    // recibe una imagen en string /base 64
    func postOCR(cuerpo:String){
                //Recupera la url de la clase conexion
        let Url = String(format: nuevaConexion.getURL())
            guard let serviceUrl = URL(string: Url) else { return }
        //se concatena la imagen en base 64
            let enviar = "data:image/png;base64,"+cuerpo
        //se guarda en la variable a pasar en el body
        let parameters: [String: Any];
        if(nuevaConexion.esSelfie()){
            parameters = ["FACE_ID":"1231212142","img": enviar]
        }else{
            parameters = ["img": enviar]
        }
            var request = URLRequest(url: serviceUrl)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .fragmentsAllowed) else {
                return
            }
            request.httpBody = httpBody
        
            request.timeoutInterval = 50
            let session = URLSession.shared
            session.dataTask(with: request) { (data, response, error) in
                if let response = response {
                    //print("response")
                    print(response)
                }
                if let data = data {
                    print(data)
                    do {
                        //Respuesta de la peticion
                        if(!data.isEmpty){
                            let json:String = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! String
                                print(json)
                                self.tituloAccion.text = json
                        }else{
                            self.tituloAccion.text = "No se econtro información"
                        }
                    } catch {
                        //Error cachado
                        print("Error")
                        self.tituloAccion.text = "Error revise el log"
                        print(error)
                    }
                }
            }.resume()
        }
    //Convierte josn any a strings
    func jsonToString(json: AnyObject){
        do {
            let data1 =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
            let convertedString = String(data: data1, encoding: String.Encoding.utf8) // the data will be converted to the string
            print(convertedString ?? "defaultvalue")
        } catch let myJSONError {
            print(myJSONError)
        }
        
    }
    func ConvertImageToBase64String (img: UIImage) -> String {
        let imageData:NSData = img.jpegData(compressionQuality: 0.50)! as NSData //UIImagePNGRepresentation(img)
        let imgString = imageData.base64EncodedString(options: .init(rawValue: 0))
        let replaced = imgString.replacingOccurrences(of: "\n", with: "")
        print(replaced)
        return replaced
    }
    
}
extension ViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        self.dataImage.image = image
    }
}
