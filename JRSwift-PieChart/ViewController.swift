//
//  ViewController.swift
//  JRswift-piechart
//
//  Created by User on 11/20/15.
//  Copyright © 2015 jrjithin. All rights reserved.
//
import UIKit

class ViewController: UIViewController, PiechartDelegate {
    
   

    @IBOutlet var piechart: Piechart!
    let divisions: [Float] = [3,5,6,5,7,6,6,0.5]
    let colors: [UIColor] = [UIColor.redColor(),UIColor.yellowColor(),UIColor.blueColor(),UIColor.greenColor(),UIColor.orangeColor(), UIColor.magentaColor(),UIColor.purpleColor(),UIColor.greenColor()]
    let images: [String] = ["dart","wash"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        piechart.delegate = self
        piechart.title = "Service"
        piechart.layer.borderWidth = 0
        piechart.divisions = divisions
        piechart.colors = colors
        
        piechart.createSlicesFromDivisions()
        
        piechart.translatesAutoresizingMaskIntoConstraints = false
            
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func setImageForItemat(index: Int)-> UIImage{
        
        return UIImage(named: images[index % 2])!
    }
    func setTextForSlice(at: Int) -> String {
        
        return "\(divisions[at])$"
        
    }
    
    func setSubtitle() -> String {
        return "Subtitle"
        
    }
    func setChartTitle(total: Float) -> String {
        return "\(total)$"
    }
    
}

