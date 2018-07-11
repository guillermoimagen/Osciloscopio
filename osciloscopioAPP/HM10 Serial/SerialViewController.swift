//
//  SerialViewController.swift
//  HM10 Serial
//
//  Created by Guillermo on 15 06 2018.
//  En esta ventana leemos los dispositivos BLE circundantes al smartphone
//

import UIKit
import CoreBluetooth
import QuartzCore
import Charts
import Photos
/// Opción para agagre un \n or \r or \r\n al final del mensaje enviado
enum MessageOption: Int {
    case noLineEnding,
         newline,
         carriageReturn,
         carriageReturnAndNewline
}

/// Opción para enviar un \n al final del mensaje recibido, para hacerlo más entendible
enum ReceivedMessageOption: Int {
    case none,
         newline
}

final class SerialViewController: UIViewController, UITextFieldDelegate, BluetoothSerialDelegate {

//MARK: IBOutlets
    // botones para prender/apagar señales
    @IBOutlet weak var sen1: UIButton!
    @IBOutlet weak var sen1t: UILabel!
    @IBOutlet weak var sen2: UIButton!
    @IBOutlet weak var sen2t: UILabel!
    @IBOutlet weak var sen3: UIButton!
    @IBOutlet weak var sen3t: UILabel!
    @IBOutlet weak var sen4: UIButton!
    @IBOutlet weak var sen4t: UILabel!
    
    // vista en la que se mostrarán los controladores
    @IBOutlet weak var abajo: UIView!
    // slider para incrementar/decrementar frecuencia de dibujo de la gráfico
    @IBOutlet weak var slider: UISlider!
    // para pausar la generación de la gráfica
    @IBOutlet weak var botonPlayPause: UIButton!
    // la gráfica
    @IBOutlet weak var chartView: LineChartView!
    
    // elementos adicionales
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint! // used to move the textField up when the keyboard is present
    @IBOutlet weak var barButton: UIBarButtonItem!
    @IBOutlet weak var navItem: UINavigationItem!

    // Arreglos en donde almacenaremos los datos de las cuatro entradas de datos, los usamos para poder pintar la gráfica en tiempo real
    var yEntries1 = [ChartDataEntry]()
    var yEntries2 = [ChartDataEntry]()
    var yEntries3 = [ChartDataEntry]()
    var yEntries4 = [ChartDataEntry]()
    // contador de ayuda para la gráfica
    var currentCount = 0.0

    // frecuencia de dibujo predeterminada
    var step = 0.5
    
    // para controlar si la gráfica se está generando en tiempo real
    var reproduciendo=true;
    
    // para controlar si las señales 1 a 4 se están mostrando
    var sen1B=true
    var sen2B=true
    var sen3B=true
    var sen4B=true
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true);
        
    }
//MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // definimos la comunicación serial por bluetooth
        serial = BluetoothSerial(delegate: self)
        
        // pintamos por primera vez la vista que indica si estamos conectados a un dispositivo y los botones correspondientes
        reloadView()
        
        // agregamosuna notificación para cuando desde el selector de dispositivos bluetooth se haya conectado un nuevo dispositivo o desconectado un dispositivo existente
        NotificationCenter.default.addObserver(self, selector: #selector(SerialViewController.reloadView), name: NSNotification.Name(rawValue: "reloadStartViewController"), object: nil)
        
        // le damos estilo a la vista inferior
        bottomView.layer.masksToBounds = false
        bottomView.layer.shadowOffset = CGSize(width: 0, height: -1)
        bottomView.layer.shadowRadius = 0
        bottomView.layer.shadowOpacity = 0.5
        bottomView.layer.shadowColor = UIColor.gray.cgColor
        
        arranca() // configuramos la gráfica inicialmente
    }
    
    func arranca()
    {
        // definimos elementos generales de la gráfica
        chartView.gridBackgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        chartView.drawGridBackgroundEnabled=false
        chartView.chartDescription?.text="";
        
        // configuramos el eje izquierdo
        let leftAxis = chartView.leftAxis
        leftAxis.axisMaximum = 5
        leftAxis.axisMinimum = -5
        leftAxis.labelTextColor = UIColor.white
        
        // configuramos el eje derecho
        let rightAxis = chartView.rightAxis
        rightAxis.drawLabelsEnabled=false
        rightAxis.drawGridLinesEnabled=false
        initData() // inicializamos la gráfica
    }
    
    func initData()
    {
        // configuramos el eje X
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.axisMinimum = 0.0
        xAxis.axisMaximum = 10.0
        xAxis.labelTextColor = UIColor.white

        // inicializamos el contador
        currentCount = 0
        
        // limpiamos los arreglos que almacenan los datos de la gráfica
        yEntries1.removeAll()
        yEntries2.removeAll()
        yEntries3.removeAll()
        yEntries4.removeAll()
        
        // configuramos la serie 1 de la gráfica
        var set1 = LineChartDataSet()
        set1 = LineChartDataSet(values: yEntries1, label: "")
        set1.axisDependency = .left
        set1.highlightColor = .black
        set1.highlightLineDashPhase = 1.0
        set1.drawCirclesEnabled=false;
        set1.drawValuesEnabled=false;
        set1.drawFilledEnabled=false;
        set1.mode = .cubicBezier
        if(sen1B) // está prendida, se muestra
        {
            sen1.tintColor=UIColor.white
            sen1t.textColor=UIColor.white
            set1.setColor(UIColor.white)
        }
        else // está apagada, la ocultamos
        {
            sen1.tintColor=UIColor.gray
            sen1t.textColor=UIColor.gray
            set1.setColor(UIColor.clear)
        }
        
        // configuramos la serie 2 de la gráfica
        var set2 = LineChartDataSet()
        set2 = LineChartDataSet(values: yEntries2, label: "")
        set2.axisDependency = .left
        set2.highlightColor = .black
        set2.highlightLineDashPhase = 1.0
        set2.drawCirclesEnabled=false;
        set2.drawValuesEnabled=false;
        set2.drawFilledEnabled=false;
        set2.mode = .cubicBezier
        if(sen2B) // está prendida, se muestra
        {
            sen2.tintColor=UIColor.yellow
            sen2t.textColor=UIColor.yellow
            set2.setColor(UIColor.yellow)
        }
        else // está apagada, la ocultamos
        {
            sen2.tintColor=UIColor.gray
            sen2t.textColor=UIColor.gray
            set2.setColor(UIColor.clear)
        }
        
        // configuramos la serie 3 de la gráfica
        var set3 = LineChartDataSet()
        set3 = LineChartDataSet(values: yEntries3, label: "")
        set3.axisDependency = .left
        set3.highlightColor = .black
        set3.highlightLineDashPhase = 1.0
        set3.drawCirclesEnabled=false;
        set3.drawValuesEnabled=false;
        set3.drawFilledEnabled=false;
        set3.mode = .cubicBezier
        if(sen3B) // está prendida, se muestra
        {
            sen3.tintColor=UIColor.orange
            sen3t.textColor=UIColor.orange
            set3.setColor(UIColor.orange)
        }
        else // está apagada, la ocultamos
        {
            sen3.tintColor=UIColor.gray
            sen3t.textColor=UIColor.gray
            set3.setColor(UIColor.clear)
        }
        
        // configuramos la serie 4 de la gráfica
        var set4 = LineChartDataSet()
        set4 = LineChartDataSet(values: yEntries3, label: "")
        set4.axisDependency = .left
        set4.highlightColor = .black
        set4.highlightLineDashPhase = 1.0
        set4.drawCirclesEnabled=false;
        set4.drawValuesEnabled=false;
        set4.drawFilledEnabled=false;
        set4.mode = .cubicBezier
        if(sen4B) // está prendida, se muestra
        {
            sen4.tintColor=UIColor.green
            sen4t.textColor=UIColor.green
            set4.setColor(UIColor.green)
        }
        else // está apagada, la ocultamos
        {
            sen4.tintColor=UIColor.gray
            sen4t.textColor=UIColor.gray
            set4.setColor(UIColor.clear)
        }

        
        var dataSets = [LineChartDataSet]()
        dataSets.append(set1)
        dataSets.append(set2)
        dataSets.append(set3)
        dataSets.append(set4)

        let data = LineChartData(dataSets: dataSets)
        data.setValueTextColor(UIColor.blue)
        chartView.data = data
    }
    
    // vamos a pintar los valores de la gráficas
    @objc func addValuesToChart(var1:Double, var2:Double, var3:Double, var4:Double)
    {
        // creamos los datos de la gráfica en cada una de las series y las agregamos a la serie correspondiente
        let chartEntry = ChartDataEntry(x: currentCount, y: var1)
        yEntries1.append(chartEntry)
        
        let chartEntry2 = ChartDataEntry(x: currentCount, y: var2)
        yEntries2.append(chartEntry2)
        
        let chartEntry3 = ChartDataEntry(x: currentCount, y: var3)
        yEntries3.append(chartEntry3)
        
        let chartEntry4 = ChartDataEntry(x: currentCount, y: var4)
        yEntries4.append(chartEntry4)
       
        // llegamos al máximo de la gráfica resetearemos los ejes
        if yEntries1.count == Int(10 / step)
        {
            chartView.xAxis.resetCustomAxisMax()
            chartView.xAxis.resetCustomAxisMin()
        }
        
        // llegamos al máximo de la gráfica o nos pasamos, quitamos el primer elemento de los arreglos para pintar en el tiempo (simulado)
        if yEntries1.count >= Int(10 / step)
        {
            yEntries1.removeFirst()
            yEntries2.removeFirst()
            yEntries3.removeFirst()
            yEntries4.removeFirst()
        }

        // movemos la gráfica a la posición actual
        chartView.moveViewToX(Double(currentCount))
        
        // incrementamos el contador
        currentCount = currentCount + step
        
        // asignamos las series generadas (arreglo) a las series de la gráfica
        var set1 = LineChartDataSet()
        set1 = (chartView.data?.dataSets[0] as? LineChartDataSet)!
        set1.values = yEntries1
        
        var set2 = LineChartDataSet()
        set2 = (chartView.data?.dataSets[1] as? LineChartDataSet)!
        set2.values = yEntries2
        
        var set3 = LineChartDataSet()
        set3 = (chartView.data?.dataSets[2] as? LineChartDataSet)!
        set3.values = yEntries3
        
        var set4 = LineChartDataSet()
        set4 = (chartView.data?.dataSets[3] as? LineChartDataSet)!
        set4.values = yEntries4
        
        // repintamos las gráficas con los arreglos asignados
        chartView.data?.notifyDataChanged()
        chartView.notifyDataSetChanged()
    }
    
    // botón pausa/reproducir
    @IBAction func pauseButton(_ sender: Any) {
        
        if(reproduciendo) // está reproduciendo, pausaremos
        {
            reproduciendo=false
            botonPlayPause.setImage(UIImage(named: "play"), for: .normal)
        }
        else // está pausado, reproduciremos
        {
            reproduciendo=true
            botonPlayPause.setImage(UIImage(named: "pausa"), for: .normal)
        }
    }
    
    // resetear la gráfica
    @IBAction func resetData(_ sender: Any) {
        if(!reproduciendo) // no está reproduciendo
        {
            reproduciendo=true // comenzamos a reproducir
             botonPlayPause.setImage(UIImage(named: "pausa"), for: .normal)
        }
        initData() // inicializamos
    }

    // destruimos la notificación del notification center
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // cuando se minimiza la app o se abre la ventana de selección de BLE
    func reloadView() {
        
        // volveremos a asignar el delegate del BLE
        serial.delegate = self
        
        if serial.isReady { // está conectado el BLE
            navItem.title = "Osciloscopio"
            barButton.title = "Desconectar"
            barButton.tintColor = UIColor.red
            barButton.isEnabled = true
            abajo.isUserInteractionEnabled=true
            abajo.alpha=1
        } else if serial.centralManager.state == .poweredOn { // no está conectado el BLE
            navItem.title = "Osciloscopio"
            barButton.title = "Conectar"
            barButton.tintColor = view.tintColor
            barButton.isEnabled = true
            abajo.isUserInteractionEnabled=false
            abajo.alpha=0.5
        } else {
            navItem.title = "Osciloscopio"
            barButton.title = "Conectar"
            barButton.tintColor = view.tintColor
            barButton.isEnabled = false
            abajo.isUserInteractionEnabled=false
            abajo.alpha=05
        }
    }
    
    

//MARK: BluetoothSerialDelegate
    
    // recibimos un string del BLE
    func serialDidReceiveString(_ message: String) {
        if(reproduciendo) // estamos reproduciendo
        {
            var messa2=message;
            messa2.remove(at: messa2.index(before: messa2.endIndex))
            // separamos la cadena en un arreglo
            var partes = messa2.components(separatedBy: " ")
            
            // inicializamos a 0 los valores
            var parte1="0"
            var parte2="0"
            var parte3="0"
            var parte4="0"

            // asignamos los elementos del arreglo a valores
            parte1 = partes[0]
            if(partes.count>=2)
            {
                parte2 = partes[1]
            }
            if(partes.count>=3)
            {
                parte3 = partes[2]
            }
            if(partes.count>=4)
            {
                parte4 = partes[3]
            }
            
            // agregamos los valores encontrados a la gráfica
            addValuesToChart(var1: (parte1 as NSString).doubleValue*5/1024, var2: (parte2 as NSString).doubleValue*5/1024, var3: (parte3 as NSString).doubleValue*5/1024, var4: (parte4 as NSString).doubleValue*5/1024)
        }
        
    }
    
    // Se desconectó el BLE
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        reloadView()
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = "Desconectado"
        hud?.hide(true, afterDelay: 1.0)
    }
    
    // El BLE cambió de estado
    func serialDidChangeState() {
        reloadView()
        if serial.centralManager.state != .poweredOn {
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud?.mode = MBProgressHUDMode.text
            hud?.labelText = "Bluetooth apagado"
            hud?.hide(true, afterDelay: 1.0)
        }
    }
    
    // Clic en el botón de play/pausa
    @IBAction func cambio(_ sender: Any) {
        reproduciendo=false
        step=Double(slider.value)
        reproduciendo=true
        botonPlayPause.setImage(UIImage(named: "pausa"), for: .normal)
        initData()
    }
    
    // Aviso de imagen guardada
    func cargaAviso() {
        let hud2 = MBProgressHUD.showAdded(to: view, animated: true)
        hud2?.mode = MBProgressHUDMode.text
        hud2?.labelText = "Imagen guardada"
        hud2?.hide(true, afterDelay: 1.0)
    }
    
    // click en botón tomar foto
    @IBAction func tomarFoto(_ sender: Any) {
        // suspendemos la reproducción
        reproduciendo=false
        botonPlayPause.setImage(UIImage(named: "play"), for: .normal)
        
        // guardamos la vista de la gráfica en una UIImage
        UIGraphicsBeginImageContextWithOptions(chartView.bounds.size, chartView.isOpaque, 0.0)
        chartView.drawHierarchy(in: chartView.bounds, afterScreenUpdates: false)
        let snapshotImageFromMyView = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        // Guardaremos la UIImage en la librería de imágenes del dispositivo
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: snapshotImageFromMyView!)
        }, completionHandler: { success, error in
            
        })
        self.cargaAviso()
    }
    
    // encendemos y apagamos señal 1
    @IBAction func sen1C(_ sender: Any) {
        if(sen1B){ sen1B=false }
        else { sen1B=true }
        initData()
    }
    // encendemos y apagamos señal 2
    @IBAction func sen2C(_ sender: Any) {
        if(sen2B){ sen2B=false }
        else { sen2B=true }
        initData()
    }
    // encendemos y apagamos señal 3
    @IBAction func sen3C(_ sender: Any) {
        if(sen3B){ sen3B=false }
        else { sen3B=true }
        initData()
    }
    // encendemos y apagamos señal 4
    @IBAction func sen4C(_ sender: Any) {
        if(sen4B){ sen4B=false }
        else { sen4B=true }
        initData()
    }
    
//MARK: IBActions

    // Abrimos el buscador de señales BLE
    @IBAction func barButtonPressed(_ sender: AnyObject) {
        
        if serial.connectedPeripheral == nil {
            performSegue(withIdentifier: "ShowScanner", sender: self)
        } else {
            serial.disconnect()
            reloadView()
        }
    }
}
