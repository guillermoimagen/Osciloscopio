//
//  ScannerViewController.swift
//  Osciloscopio
//
//  Created by Guillermo on 15 06 2018.
//  En esta ventana leemos los dispositivos BLE circundantes al smartphone
//
//



import UIKit
import CoreBluetooth

final class ScannerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, BluetoothSerialDelegate {

//MARK: IBOutlets
    
    @IBOutlet weak var tryAgainButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    
//MARK: Variables
    
    /// Dispositivos encontrados (Sin duplicados y ordenados por asc RSSI)
    var peripherals: [(peripheral: CBPeripheral, RSSI: Float)] = []
    
    /// El dispositivos que el usuario seleccionó
    var selectedPeripheral: CBPeripheral?
    
    /// Indicador de proreso
    var progressHUD: MBProgressHUD?
    
    
//MARK: Funciones
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tryAgainButton solamente está habilitado cuando no estamos buscando
        tryAgainButton.isEnabled = false

        // ajustamos el bottom del tableview
        tableView.tableFooterView = UIView(frame: CGRect.zero)

        // Le decimos al delegate que nos notifique en esta ventana en lugar de hacerlo en la vista pregvia en caso de que algo ocurra
        serial.delegate = self
        
        if serial.centralManager.state != .poweredOn {
            title = "El Bluetooth está apagado"
            return
        }
        
        // Vamos a comenzar a escanear y creamos un timeout
        serial.startScan()
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(ScannerViewController.scanTimeOut), userInfo: nil, repeats: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Tiramos recursos que podamos
    }
    
    /// Debe ser llamada 10 segundos después de que comenzamos a escanear
    func scanTimeOut() {
        // Se acabó el tiempo. Detendremos el escaneo y le daremos al usuario la opción de intentar otra vez
        serial.stopScan()
        tryAgainButton.isEnabled = true
        title = "Terminé de buscar"
    }
    
    /// Lo llamaremos 10 segundos después de que comenzamos a conectarnos
    func connectTimeOut() {
        
        // No hacemos nada si ya estamos conectados
        if let _ = serial.connectedPeripheral {
            return
        }
        
        if let hud = progressHUD {
            hud.hide(false)
        }
        
        if let _ = selectedPeripheral {
            serial.disconnect()
            selectedPeripheral = nil
        }
        
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = "Falló al conectar"
        hud?.hide(true, afterDelay: 2)
    }
    
    
//MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Cada renglón de la tabla contiene un dispositivo con el nombre en ella
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let label = cell.viewWithTag(1) as! UILabel!
        label?.text = peripherals[(indexPath as NSIndexPath).row].peripheral.name
        return cell
    }
    
    
//MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        // El usuario selección un dispositivo, entonces dejamos de escanear y conectamos
        serial.stopScan()
        selectedPeripheral = peripherals[(indexPath as NSIndexPath).row].peripheral
        serial.connectToPeripheral(selectedPeripheral!)
        progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
        progressHUD!.labelText = "Conectando"
        
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(ScannerViewController.connectTimeOut), userInfo: nil, repeats: false)
    }
    
    
//MARK: BluetoothSerialDelegate
    
    // encontramos un dispositivo
    func serialDidDiscoverPeripheral(_ peripheral: CBPeripheral, RSSI: NSNumber?) {
        // checamos si está duplicado
        for exisiting in peripherals {
            if exisiting.peripheral.identifier == peripheral.identifier { return }
        }
        
        // lo agregamos al arreglo y ordenamos el arreglo por RSSI
        let theRSSI = RSSI?.floatValue ?? 0.0
        peripherals.append(peripheral: peripheral, RSSI: theRSSI)
        peripherals.sort { $0.RSSI < $1.RSSI }
        tableView.reloadData()
    }
    
    // hubo un error de conexión al dispositivo
    func serialDidFailToConnect(_ peripheral: CBPeripheral, error: NSError?) {
        if let hud = progressHUD {
            hud.hide(false)
        }
        
        tryAgainButton.isEnabled = true
                
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = "Falló al conectar"
        hud?.hide(true, afterDelay: 1.0)
    }
    
    // el dispositivo se desconectó
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        if let hud = progressHUD {
            hud.hide(false)
        }
        
        tryAgainButton.isEnabled = true
        
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = "Falló al conectar"
        hud?.hide(true, afterDelay: 1.0)

    }
    
    // el dispositivo está listo, recargamos la ventana principal y cerramos ésta
    func serialIsReady(_ peripheral: CBPeripheral) {
        if let hud = progressHUD {
            hud.hide(false)
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadStartViewController"), object: self)
        dismiss(animated: true, completion: nil)
    }
    
    // Hubo un cambio de estado en el dispositivo, entonces recargamos la principal y cerra ésta
    func serialDidChangeState() {
        if let hud = progressHUD {
            hud.hide(false)
        }
        
        if serial.centralManager.state != .poweredOn {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadStartViewController"), object: self)
            dismiss(animated: true, completion: nil)
        }
    }
    

//MARK: IBActions
    
    // detengamos el escaneo
    @IBAction func cancel(_ sender: AnyObject) {
        // go back
        serial.stopScan()
        dismiss(animated: true, completion: nil)
    }

    // intentemos otra vez
    @IBAction func tryAgain(_ sender: AnyObject) {
        // empty array an start again
        peripherals = []
        tableView.reloadData()
        tryAgainButton.isEnabled = false
        title = "Buscando ..."
        serial.startScan()
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(ScannerViewController.scanTimeOut), userInfo: nil, repeats: false)
    }
    
}
