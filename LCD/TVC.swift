//
//  TVC.swift
//  LCD
//
//  Created by Carlos Buitrago on 4/04/16.
//  Copyright © 2016 Carlos Buitrago. All rights reserved.
//

import UIKit
import CoreData



class TVC: UITableViewController,UITextFieldDelegate, PasarInfo {
    var libros :Array<Array<String>> = Array<Array<String>>()
    var contexto:NSManagedObjectContext? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Libros"
        self.contexto = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        let seccionEntidad = NSEntityDescription.entityForName("Dato", inManagedObjectContext: self.contexto!)
        let peticion = seccionEntidad?.managedObjectModel.fetchRequestTemplateForName("petSecciones")
        do{
            let seccionesEntidad = try self.contexto?.executeFetchRequest(peticion!)
            for seccionesEntidad2 in seccionesEntidad!{
                let nombre = seccionesEntidad2.valueForKey("nombre") as! String
                let isbn = seccionesEntidad2.valueForKey("isbn") as! String
                self.libros.append([nombre,isbn])
            }
        }
        catch{
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.libros.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("celda", forIndexPath: indexPath)
        
        // Configure the cell...
        
        cell.textLabel?.text = self.libros[indexPath.row][0]
        return cell
    }
    
    func libro(titulo: String, ISBN: String)
    {
        libros.append([titulo ,ISBN])
        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths([
            NSIndexPath(forRow: libros.count-1, inSection: 0)
            ], withRowAnimation: .Automatic)
        self.tableView.endUpdates()
        
    }
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let cc = segue.destinationViewController as! ViewController
        let ip = self.tableView.indexPathForSelectedRow
        if ip == nil{
            cc.codigo = ""
        }
        else{
            cc.codigo = self.libros[ip!.row][1]
        }
        cc.delegate = self
    }

}
