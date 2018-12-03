//
//  PreviewViewController.swift
//  Printing
//
//  Created by Apple on 03/12/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import MessageUI


class PreviewViewController: UIViewController {
    @IBOutlet weak var webPreview: UIWebView!
    var invoiceInfo: [String: AnyObject]!
    var invoiceComposer: InvoiceComposer!
    var HTMLContent: String!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createInvoiceAsHTML()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // MARK: IBAction Methods
    @IBAction func exportToPDF(_ sender: AnyObject) {
        
        print(HTMLContent)
        //Export or genrate pdf File
        invoiceComposer.exportHTMLContentToPDF(HTMLContent: HTMLContent)
        showOptionsAlert() //KCK
    }
    
    // MARK: Custom Methods
    func createInvoiceAsHTML() {
        invoiceComposer = InvoiceComposer()
        if let invoiceHTML = invoiceComposer.renderInvoice(invoiceNumber: invoiceInfo["invoiceNumber"] as! String, invoiceDate: invoiceInfo["invoiceDate"] as! String, recipientInfo: invoiceInfo["recipientInfo"] as! String, items: invoiceInfo["items"] as! [[String: String]], totalAmount: invoiceInfo["totalAmount"] as! String) {
            
            webPreview.loadHTMLString(invoiceHTML, baseURL: NSURL(string: invoiceComposer.pathToInvoiceHTMLTemplate!)! as URL)
            HTMLContent = invoiceHTML
        }
    }
    
    func showOptionsAlert() {
        let alertController = UIAlertController(title: "Yeah!", message: "Your invoice has been successfully printed to a PDF file.\n\nWhat do you want to do now?", preferredStyle: UIAlertController.Style.alert)
        
        let actionPreview = UIAlertAction(title: "Preview it", style: UIAlertAction.Style.default) { (action) in
            if let filename = self.invoiceComposer.pdfFilename, let url = URL(string: filename) {
                let request = URLRequest(url: url)
                self.webPreview.loadRequest(request)
            }
        }
        
        let actionEmail = UIAlertAction(title: "Send by Email", style: UIAlertAction.Style.default) { (action) in
            DispatchQueue.main.async {
                self.sendEmail()
            }
        }
        let actionPrint = UIAlertAction(title: "Print", style: UIAlertAction.Style.default) { (action) in
            DispatchQueue.main.async {
                let textWithNewCarriageReturns = self.HTMLContent
                let printController = UIPrintInteractionController.shared
                let printInfo = UIPrintInfo(dictionary: nil)
                printInfo.outputType = UIPrintInfo.OutputType.general
                printController.printInfo = printInfo
                
                let format = UIMarkupTextPrintFormatter(markupText: textWithNewCarriageReturns!)
                format.perPageContentInsets.top = 72
                format.perPageContentInsets.bottom = 72
                format.perPageContentInsets.left = 72
                format.perPageContentInsets.right = 72
                printController.printFormatter = format
                
                printController.present(animated: true, completionHandler: nil)
            }
        }
        
        let actionNothing = UIAlertAction(title: "Nothing", style: UIAlertAction.Style.default) { (action) in
            
        }
        alertController.addAction(actionPreview)
        alertController.addAction(actionEmail)
        alertController.addAction(actionPrint)
        alertController.addAction(actionNothing)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.setSubject("Invoice")
            mailComposeViewController.addAttachmentData(NSData(contentsOfFile: invoiceComposer.pdfFilename)! as Data, mimeType: "application/pdf", fileName: "Invoice")
            present(mailComposeViewController, animated: true, completion: nil)
        }
    }
}
