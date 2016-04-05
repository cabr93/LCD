//
//  ViewController.swift
//  LCD
//
//  Created by Carlos Buitrago on 3/04/16.
//  Copyright © 2016 Carlos Buitrago. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITextFieldDelegate {

    
    @IBOutlet weak var texto: UITextView!
    @IBOutlet weak var caratu: UIImageView!
    @IBOutlet weak var isbn: UITextField!
    
    let urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
    var contexto : NSManagedObjectContext? = nil
    var delegate: PasarInfo?
    var codigo = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.contexto = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        texto.font = UIFont.systemFontOfSize(16)
        texto.font = UIFont.boldSystemFontOfSize(14)
        texto.editable = false
        if codigo != ""{
            isbn.enabled = false
            let seccionEntidad = NSEntityDescription.entityForName("Dato", inManagedObjectContext: self.contexto!)
            let req = NSFetchRequest()
            req.entity = seccionEntidad
            //let predicado = NSPredicate(format: "nombre = '\(isbn)'")
            //req.predicate = predicado
            do{
                let res = try self.contexto?.executeFetchRequest(req)
                for obj in res!{
                    let lib = obj.valueForKey("isbn") as! String
                    if lib == codigo{
                        let titulo = obj.valueForKey("nombre") as! String
                        let autores = obj.valueForKey("autores") as! String
                        let todo:String = "Titulo:\n" + titulo + "\nAutores:\n" + autores
                        texto.text = todo
                        let ff = UIImage(data: obj.valueForKey("caratula") as! NSData)
                        caratu.image = ff
                    }
                }
            }
            catch{
                
            }
        }
        else{
            isbn.enabled = true
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func mostra(isbn:String?){
        //let fetchRequest = NSFetchRequest(entityName: "Seccion")
        let seccionEntidad = NSEntityDescription.entityForName("Dato", inManagedObjectContext: self.contexto!)
        let req = NSFetchRequest()
        req.entity = seccionEntidad
        //let predicado = NSPredicate(format: "nombre = '\(isbn)'")
        //req.predicate = predicado
        do{
            let res = try self.contexto?.executeFetchRequest(req)
            for obj in res!{
                let lib = obj.valueForKey("isbn") as! String
                if lib == isbn{
                    let titulo = obj.valueForKey("nombre") as! String
                    let autores = obj.valueForKey("autores") as! String
                    let todo:String = "Titulo:\n" + titulo + "\nAutores:\n" + autores
                    texto.text = todo
                    let ff = UIImage(data: obj.valueForKey("caratula") as! NSData)
                    caratu.image = ff
                }
            }
        }
        catch{
            
        }
    }
    @IBAction func buscar(sender: UITextField) {
        sender.resignFirstResponder()
        let seccionEntidad = NSEntityDescription.entityForName("Dato", inManagedObjectContext: self.contexto!)
        let peticion = seccionEntidad?.managedObjectModel.fetchRequestFromTemplateWithName("petSeccion", substitutionVariables: ["isbn": sender.text!])
        do{
            let secionEntidad2 = try self.contexto?.executeFetchRequest(peticion!)
            if (secionEntidad2?.count > 0){
                mostra(sender.text)
                return
            }
        }
        catch{
            
        }
        
        let texIn = sender.text!
        
        var titulo : String = ""
        var caratula =  UIImage(named: "blanco.jpg")
        var autores :String = ""
        
        let urls2 = urls + texIn
        let url = NSURL(string: urls2)
        let datos = NSData(contentsOfURL: url!)
        if datos == nil{
            let alert = UIAlertController(title:"Error", message: "No hay conexion a Internet", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        else {
            let textoS = NSString(data: datos!, encoding: NSUTF8StringEncoding)
            if textoS as! String == "{}"{
                let alert = UIAlertController(title:"Error", message: "El ISBN no existe", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                presentViewController(alert, animated: true, completion: nil)
                return
            }
            else{
                do{
                    let json = try NSJSONSerialization.JSONObjectWithData(datos!, options: NSJSONReadingOptions.MutableLeaves)
                    let dico1 = json as! NSDictionary
                    let dico2 = dico1["ISBN:"+texIn] as! NSDictionary
                    titulo = dico2["title"] as! NSString as String// titulo
                    let dico3 = dico2["authors"] as! [NSDictionary]
                    for i in dico3{
                        if autores == ""{
                            autores += "-"
                            autores += i["name"] as! NSString as String
                        }else{
                            autores += "\n-"
                            autores += i["name"] as! NSString as String
                        }
                    }
                    let dico4 = dico2["cover"] as! NSDictionary?
                    if dico4 != nil{
                        let foto = dico4!["large"]as! NSString as String
                        let fot = NSURL(string: foto)
                        let dat = NSData(contentsOfURL: fot!)
                        caratula = UIImage(data:dat!)//caratula
                    }
                }
                catch _ {
                    
                }
            }
        }
        let todo:String = "Titulo:\n" + titulo + "\nAutores:\n" + autores
        texto.text = todo
        caratu.image = caratula
        self.delegate?.libro(titulo, ISBN: texIn)
        let nuevaSeccionEntidad = NSEntityDescription.insertNewObjectForEntityForName("Dato", inManagedObjectContext: self.contexto!)
        nuevaSeccionEntidad.setValue(sender.text, forKey: "isbn")
        nuevaSeccionEntidad.setValue(titulo, forKey: "nombre")
        nuevaSeccionEntidad.setValue(autores, forKey: "autores")
        nuevaSeccionEntidad.setValue(UIImagePNGRepresentation(caratula!), forKey: "caratula")
        do{
            try self.contexto?.save()
        }
        catch{
            
        }
    }
}