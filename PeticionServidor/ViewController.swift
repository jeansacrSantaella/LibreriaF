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
    var comprobante:Bool=false
    var selfie:Bool=false
    var faceID:String=""

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
        self.comprobante=false
        self.selfie=true
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
    
    @IBAction func tomarTrasera(_ sender: Any) {
        //se asigna la nueva URL
        nuevaConexion.setURL(nueva: "https://d2qx3bqvr4h3ci.cloudfront.net/reverso/")
        nuevaConexion.tipoOtro()
        self.comprobante=false
        self.selfie=false
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
        self.comprobante=false
        self.selfie=false
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
        self.comprobante=true
        self.selfie=false
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
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

            // para cortar la imagen
             /*if let img = info[.editedImage] as? UIImage {
                self.dataImage.image = img
                } else if let img = info[.originalImage] as? UIImage {
                    self.dataImage.image = img
                }
            if(self.comprobante){
                //rotar imagen es en radianes
                self.dataImage.image = self.dataImage.image?.rotate(radians: 4.71239)
                //self.dataImage.image = self.dataImage.image?.rotate(radians: 1.5708)
            }*/

            let _:NSData = pickedImage.pngData()! as NSData
            //Convertir a base64
            tituloAccion.text = "Procesando..."
            let strBase64 = ConvertImageToBase64String(img: pickedImage)
            nuevaConexion.setImagen(nuevaImagen: strBase64)
            nuevaConexion.crearConexion {
                salida in
                self.tituloAccion.text = salida
                if(self.selfie){
                var replaced = salida.replacingOccurrences(of: "[{\"resultado\":", with: "")
                replaced = replaced.replacingOccurrences(of: "}]", with: "")
                let jsre=replaced.toDictionary()
                let res = jsre["FACE_ID"]
                let str1 = String (describing: res)
                                let str0 = str1.replacingOccurrences(of: "Optional({", with: "")
                                let str = str0.replacingOccurrences(of: "VALOR =", with:"")
                                let str2 = str.replacingOccurrences(of: ";", with: "")
                                let str3 = str2.replacingOccurrences(of: "})", with: "")
                                let trimed = str3.trimmingCharacters(in: .whitespacesAndNewlines)
                                let integer = Int(trimed) ?? 0
                                self.faceID=trimed
                        print(trimed)
                    self.nuevaConexion.setFaceId(nuevoFaceid: trimed)
                                print (integer)
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
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
        //let targetSize = CGSize(width: 450, height: 250)
        let targetSize = CGSize(width: 350, height: 200)
               let widthScaleRatio = targetSize.width / img.size.width
               let heightScaleRatio = targetSize.height / img.size.height
               
               let scaleFactor = min(widthScaleRatio, heightScaleRatio)
               
               let scaledImageSize = CGSize(
                   width: img.size.width * scaleFactor,
                   height: img.size.height * scaleFactor
               )
               let renderer = UIGraphicsImageRenderer(
                          size: scaledImageSize
                      )

        _ = renderer.image { _ in
                          img.draw(in: CGRect(
                              origin: .zero,
                              size: scaledImageSize
                          ))
                      }
        let imageData:NSData = img.jpegData(compressionQuality: 0.10)! as NSData //UIImagePNGRepresentation(img)
        let imgString = imageData.base64EncodedString(options: .init(rawValue: 0))
        //let replaced = imgString.replacingOccurrences(of: "\n", with: "")
        print(imgString.count)
        return imgString
    }
    
    
}
extension ViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        self.dataImage.image = image
    }
}

extension UIImage {
    func cropped(boundingBox: CGRect) -> UIImage? {
        guard let cgImage = self.cgImage?.cropping(to: boundingBox) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}

extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return rotatedImage ?? self
        }

        return self
    }
}

extension String{
   func toDictionary() -> NSDictionary {
       let blankDict : NSDictionary = [:]
       if let data = self.data(using: .utf8) {
           do {
               return try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
           } catch {
               print(error.localizedDescription)
           }
       }
       return blankDict
   }
}
