package com.kerdan.supercompara;

import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.content.Intent;
import android.graphics.Color;
import android.os.Handler;
import android.os.Bundle;
import android.os.Message;
import android.support.v4.content.ContextCompat;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.github.mikephil.charting.charts.LineChart;
import com.github.mikephil.charting.components.Legend;
import com.github.mikephil.charting.components.XAxis;
import com.github.mikephil.charting.components.YAxis;
import com.github.mikephil.charting.data.Entry;
import com.github.mikephil.charting.data.LineData;
import com.github.mikephil.charting.data.LineDataSet;


import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.UUID;

public class MainActivity extends Activity {

    Button btnOn, btnOff;
    TextView txtArduino, txtString, txtStringLength, sensorView0, sensorView1, sensorView2, sensorView3;
    Handler bluetoothIn;

    final int handlerState = 0;                        //used to identify handler message
    private BluetoothAdapter btAdapter = null;
    private BluetoothSocket btSocket = null;
    private StringBuilder recDataString = new StringBuilder();

    private ConnectedThread mConnectedThread;

    // SPP UUID service - this should work for most devices
    private static final UUID BTMODULEUUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");

    // String for MAC address
    private static String address;

    private int etiqueta=0;

    private boolean shows1=true;
    private boolean shows2=true;
    private boolean shows3=true;
    private boolean shows4=true;

    private boolean reproducir=true;

    private LineChart chart;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_main);




        //Link the buttons and textViews to respective views

        LinearLayout LL_refresh=(LinearLayout) findViewById(R.id.LL_refresh);

        LinearLayout LL_camara=(LinearLayout) findViewById(R.id.LL_camara);
        LinearLayout LL_stop=(LinearLayout) findViewById(R.id.LL_stop);
        final ImageView iv_sp=(ImageView) findViewById(R.id.iv_sp);

        LinearLayout LL_s1=(LinearLayout) findViewById(R.id.LL_s1);
        LinearLayout LL_s2=(LinearLayout) findViewById(R.id.LL_s2);
        LinearLayout LL_s3=(LinearLayout) findViewById(R.id.LL_s3);
        LinearLayout LL_s4=(LinearLayout) findViewById(R.id.LL_s4);

        final TextView tv_s1=(TextView) findViewById(R.id.tv_s1);
        final TextView tv_s2=(TextView) findViewById(R.id.tv_s2);
        final TextView tv_s3=(TextView) findViewById(R.id.tv_s3);
        final TextView tv_s4=(TextView) findViewById(R.id.tv_s4);

        final ImageView iv_s1=(ImageView) findViewById(R.id.iv_s1);
        final ImageView iv_s2=(ImageView) findViewById(R.id.iv_s2);
        final ImageView iv_s3=(ImageView) findViewById(R.id.iv_s3);
        final ImageView iv_s4=(ImageView) findViewById(R.id.iv_s4);



        LL_refresh.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                bluetoothIn = new Handler();
                bluetoothIn.removeCallbacksAndMessages(null);


                etiqueta=0;
                shows1=true;
                shows2=true;
                shows3=true;
                shows4=true;

                reproducir=true;



                iv_s1.setColorFilter(Color.parseColor("#FFFFFF"), android.graphics.PorterDuff.Mode.SRC_IN);
                tv_s1.setTextColor(Color.parseColor("#FFFFFF"));

                iv_s2.setColorFilter(Color.parseColor("#FFFF00"), android.graphics.PorterDuff.Mode.SRC_IN);
                tv_s2.setTextColor(Color.parseColor("#FFFF00"));

                iv_s3.setColorFilter(Color.parseColor("#FFA500"), android.graphics.PorterDuff.Mode.SRC_IN);
                tv_s3.setTextColor(Color.parseColor("#FFA500"));

                iv_s4.setColorFilter(Color.parseColor("#00FF00"), android.graphics.PorterDuff.Mode.SRC_IN);
                tv_s4.setTextColor(Color.parseColor("#00FF00"));

                chart.clear();


                init_chart();
            }
        });

        LL_camara.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {


                SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd_HHmmss");
                String currentDateandTime = sdf.format(new Date());

                chart.saveToGallery("Chart"+currentDateandTime,100);

                Toast.makeText(MainActivity.this,"captura guardada",Toast.LENGTH_LONG).show();

            }
        });

        LL_stop.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(reproducir){
                    reproducir=false;
                    iv_sp.setImageResource(R.drawable.ic_play);
                }else{
                    iv_sp.setImageResource(R.drawable.ic_pause);
                    reproducir=true;
                }
            }
        });



        LL_s1.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(shows1){
                    shows1=false;
                    tv_s1.setTextColor(Color.parseColor("#404040"));
                    iv_s1.setColorFilter(Color.parseColor("#404040"), android.graphics.PorterDuff.Mode.SRC_IN);
                }else{
                    shows1=true;
                    iv_s1.setColorFilter(Color.parseColor("#FFFFFF"), android.graphics.PorterDuff.Mode.SRC_IN);
                    tv_s1.setTextColor(Color.parseColor("#FFFFFF"));

                    chart.clear();
                    init_chart();
                }
            }
        });


        LL_s2.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(shows2){
                    shows2=false;
                    tv_s2.setTextColor(Color.parseColor("#404040"));
                    iv_s2.setColorFilter(Color.parseColor("#404040"), android.graphics.PorterDuff.Mode.SRC_IN);
                }else{
                    shows2=true;
                    iv_s2.setColorFilter(Color.parseColor("#FFFF00"), android.graphics.PorterDuff.Mode.SRC_IN);
                    tv_s2.setTextColor(Color.parseColor("#FFFF00"));

                    chart.clear();
                    init_chart();
                }
            }
        });



        LL_s3.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(shows3){

                    shows3=false;
                    tv_s3.setTextColor(Color.parseColor("#404040"));
                    iv_s3.setColorFilter(Color.parseColor("#404040"), android.graphics.PorterDuff.Mode.SRC_IN);
                }else{
                    shows3=true;
                    iv_s3.setColorFilter(Color.parseColor("#FFA500"), android.graphics.PorterDuff.Mode.SRC_IN);
                    tv_s3.setTextColor(Color.parseColor("#FFA500"));

                    chart.clear();
                    init_chart();
                }
            }
        });


        LL_s4.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(shows4){

                    shows4=false;
                    tv_s4.setTextColor(Color.parseColor("#404040"));
                    iv_s4.setColorFilter(Color.parseColor("#404040"), android.graphics.PorterDuff.Mode.SRC_IN);
                }else{
                    shows4=true;
                    iv_s4.setColorFilter(Color.parseColor("#00FF00"), android.graphics.PorterDuff.Mode.SRC_IN);
                    tv_s4.setTextColor(Color.parseColor("#00FF00"));

                    chart.clear();
                    init_chart();
                }
            }
        });



        init_chart();

    }



    private void init_chart(){


        chart = (LineChart) findViewById(R.id.chart);



        chart.setDragEnabled(true);
        chart.setScaleEnabled(true);
        chart.setDrawGridBackground(false);
        chart.setDescription("");

//************
        LineData data=new LineData();
        LineData data2=new LineData();
        LineData data3=new LineData();
        LineData data4=new LineData();



        chart.setData(data);
        chart.setData(data2);
        chart.setData(data3);
        chart.setData(data4);

        Legend l=chart.getLegend();
        l.setForm(Legend.LegendForm.LINE);
        l.setTextColor(Color.BLACK);


        XAxis xl=chart.getXAxis();
        xl.setTextColor(Color.WHITE);
        xl.setDrawGridLines(true);

        //xl.setAvoidFirstLastClipping(true);




        YAxis y1=chart.getAxisLeft();
        y1.setTextColor(Color.WHITE);
        y1.setAxisMaxValue(5f);
        y1.setAxisMinValue (-5f);
        y1.setDrawGridLines(true);

        YAxis y12=chart.getAxisRight();
        y12.setTextColor(Color.parseColor("#005864"));
        y12.setEnabled(false);



        bluetoothIn = new Handler() {
            public void handleMessage(android.os.Message msg) {
                if (msg.what == handlerState) {                                     //if message is what we want
                    String readMessage = (String) msg.obj;                                                                // msg.arg1 = bytes from connect thread
                    //recDataString.append(readMessage);

                    Log.e("readMessage",readMessage+"_");


                }
            }
        };





        /*
        bluetoothIn = new Handler() {
            public void handleMessage(android.os.Message msg) {
                if (msg.what == handlerState) {                                     //if message is what we want
                    String readMessage = (String) msg.obj;                                                                // msg.arg1 = bytes from connect thread
                    recDataString.append(readMessage);

                    Log.e("readMessage",recDataString+"_");

                    etiqueta++;

                    //keep appending to string until ~
                    int endOfLineIndex = recDataString.indexOf("~");                    // determine the end-of-line
                    if (endOfLineIndex > 0) {                                           // make sure there data before ~

                        String dataInPrint = recDataString.substring(0, endOfLineIndex);    // extract string


//                        String dataInPrint = readMessage;    // extract string



                        dataInPrint=dataInPrint.replace("#","");

                        String[] parts = dataInPrint.split("_");

                        if (recDataString.charAt(0) == '#' && reproducir)                             //if it starts with # we know it is what we are looking for
                        {
                            String sensor0 = parts[0];             //get sensor value from string between indices 1-5
                            String sensor1 = parts[1];            //same again...
                            String sensor2 = parts[2];
                            String sensor3 = parts[3];

                            //sensorView0.setText(" Sensor 0 Voltage = " + sensor0 + "V");    //update the textviews with sensor values
                            //sensorView1.setText(" Sensor 1 Voltage = " + sensor1 + "V");
                            //sensorView2.setText(" Sensor 2 Voltage = " + sensor2 + "V");
                            //sensorView3.setText(" Sensor 3 Voltage = " + sensor3 + "V");

                            //******************************
                            LineData data=chart.getData();
                            LineData data2=chart.getData();
                            LineData data3=chart.getData();
                            LineData data4=chart.getData();

                            if(data!=null){
                                LineDataSet set=data.getDataSetByIndex(0);
                                LineDataSet set2=data2.getDataSetByIndex(1);
                                LineDataSet set3=data3.getDataSetByIndex(2);
                                LineDataSet set4=data4.getDataSetByIndex(3);

                                if(set==null) {
                                    set = createSet(Color.WHITE);
                                    data.addDataSet(set);
                                }

                                if(set2==null) {
                                    set2 = createSet(Color.YELLOW);
                                    data2.addDataSet(set2);
                                }

                                if(set3==null) {
                                    set3 = createSet(Color.parseColor("#FFA500"));
                                    data3.addDataSet(set3);
                                }


                                if(set4==null) {
                                    set4 = createSet(Color.GREEN);
                                    data4.addDataSet(set4);
                                }

                                LineDataSet setset = null;

                                if(shows1) {
                                    data.addXValue(String.valueOf(etiqueta));
                                    data.addEntry(new Entry(Transforma(sensor0), set.getEntryCount()), 0);

                                    setset=set;
                                }

                                if(shows2) {

                                    data2.addXValue("");
                                    data2.addEntry(new Entry(Transforma(sensor1), set2.getEntryCount()), 1);

                                    setset=set2;
                                }

                                if(shows3) {
                                    data3.addXValue("");
                                    data3.addEntry(new Entry(Transforma(sensor2), set3.getEntryCount()), 2);

                                    setset=set3;
                                }

                                if(shows4) {
                                    data4.addXValue("");
                                    data4.addEntry(new Entry(Transforma(sensor3), set4.getEntryCount()), 3);
                                    setset=set4;
                                }


                                //******************************
                                chart.notifyDataSetChanged();
                                chart.setVisibleXRange(1,5);
                                chart.moveViewToX( setset.getEntryCount()-6);
                            }
                        }
                        recDataString.delete(0, recDataString.length());                    //clear all string data
                        // strIncom =" ";
                        dataInPrint = " ";
                    }
                }
            }
        };
        */

        btAdapter = BluetoothAdapter.getDefaultAdapter();       // get Bluetooth adapter
        checkBTState();

    }


    private LineDataSet createSet(int micolor){
        LineDataSet set=new LineDataSet(null,"");
        set.setDrawCubic(true);
        set.setLineWidth(1.5f);
        set.setHighLightColor(Color.GREEN);
        set.setDrawCircles(false);
        set.setDrawValues(false);
        set.setColor(micolor);

        set.setAxisDependency(YAxis.AxisDependency.LEFT);
        return set;
    }

    private BluetoothSocket createBluetoothSocket(BluetoothDevice device) throws IOException {

        return  device.createRfcommSocketToServiceRecord(BTMODULEUUID);
        //creates secure outgoing connecetion with BT device using UUID
    }


    private float Transforma(String valor){
        int  retorno= 0;


        valor=valor.replace("#","");

        if(valor.equals("")){
            valor="0";
        }

        retorno=Integer.parseInt(valor);

        retorno=(retorno*5)/1024;

        return retorno;
    }


    @Override
    public void onResume() {
        super.onResume();

        //Get MAC address from DeviceListActivity via intent
        Intent intent = getIntent();

        //Get the MAC address from the DeviceListActivty via EXTRA
        address = intent.getStringExtra(DeviceList.EXTRA_DEVICE_ADDRESS);

        //create device and set the MAC address
        BluetoothDevice device = btAdapter.getRemoteDevice(address);

        try {
            btSocket = createBluetoothSocket(device);
        } catch (IOException e) {
            Toast.makeText(getBaseContext(), "Socket creation failed", Toast.LENGTH_LONG).show();
        }
        // Establish the Bluetooth socket connection.
        try
        {
            btSocket.connect();
        } catch (IOException e) {
            try
            {
                btSocket.close();
            } catch (IOException e2)
            {
                //insert code to deal with this
            }
        }
        mConnectedThread = new ConnectedThread(btSocket);
        mConnectedThread.start();

        //I send a character when resuming.beginning transmission to check device is connected
        //If it is not an exception will be thrown in the write method and finish() will be called
        mConnectedThread.write("");
    }

    @Override
    public void onPause()
    {
        super.onPause();
        try
        {
            //Don't leave Bluetooth sockets open when leaving activity
            btSocket.close();
        } catch (IOException e2) {
            //insert code to deal with this
        }
    }

    //Checks that the Android device Bluetooth is available and prompts to be turned on if off
    private void checkBTState() {

        if(btAdapter==null) {
            Toast.makeText(getBaseContext(), "Device does not support bluetooth", Toast.LENGTH_LONG).show();
        } else {
            if (btAdapter.isEnabled()) {
            } else {
                Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
                startActivityForResult(enableBtIntent, 1);
            }
        }
    }

    //create new class for connect thread
    private class ConnectedThread extends Thread {
        private final InputStream mmInStream;
        private final OutputStream mmOutStream;

        //creation of the connect thread
        public ConnectedThread(BluetoothSocket socket) {
            InputStream tmpIn = null;
            OutputStream tmpOut = null;

            try {
                //Create I/O streams for connection
                tmpIn = socket.getInputStream();
                tmpOut = socket.getOutputStream();
            } catch (IOException e) { }

            mmInStream = tmpIn;
            mmOutStream = tmpOut;
        }

        public void run() {
            byte[] buffer = new byte[1024];
            int begin = 0;
            int bytes = 0;

            // Keep looping to listen for received messages
            while (true) {
                try {
                    bytes += mmInStream.read(buffer, bytes, buffer.length - bytes);
                    for(int i = begin; i < bytes; i++) {
                        if(buffer[i] == "#".getBytes()[0]) {
                            mHandler.obtainMessage(1, begin, i, buffer).sendToTarget();
                            begin = i + 1;
                            if(i == bytes - 1) {
                                bytes = 0;
                                begin = 0;
                            }
                        }
                    }
                } catch (IOException e) {
                    break;
                }
            }
        }




        Handler mHandler = new Handler() {
            @Override
            public void handleMessage(Message msg) {
                byte[] writeBuf = (byte[]) msg.obj;
                int begin = (int)msg.arg1;
                int end = (int)msg.arg2;

                switch(msg.what) {
                    case 1:
                        String writeMessage = new String(writeBuf);
                        writeMessage = writeMessage.substring(begin, end);

                        Log.e("writeMessage",writeMessage);

                        //******************************************
                        //******************************************

                        writeMessage.replace("#","");

                        String[] parts = writeMessage.split(" ");

                        if (parts.length>3 && reproducir)                             //if it starts with # we know it is what we are looking for
                        {
                            String sensor0 = parts[0];             //get sensor value from string between indices 1-5
                            String sensor1 = parts[1];            //same again...
                            String sensor2 = parts[2];
                            String sensor3 = parts[3];

                            //sensorView0.setText(" Sensor 0 Voltage = " + sensor0 + "V");    //update the textviews with sensor values
                            //sensorView1.setText(" Sensor 1 Voltage = " + sensor1 + "V");
                            //sensorView2.setText(" Sensor 2 Voltage = " + sensor2 + "V");
                            //sensorView3.setText(" Sensor 3 Voltage = " + sensor3 + "V");

                            //******************************
                            LineData data = chart.getData();
                            LineData data2 = chart.getData();
                            LineData data3 = chart.getData();
                            LineData data4 = chart.getData();

                            if (data != null) {
                                LineDataSet set = data.getDataSetByIndex(0);
                                LineDataSet set2 = data2.getDataSetByIndex(1);
                                LineDataSet set3 = data3.getDataSetByIndex(2);
                                LineDataSet set4 = data4.getDataSetByIndex(3);

                                if (set == null) {
                                    set = createSet(Color.WHITE);
                                    data.addDataSet(set);
                                }

                                if (set2 == null) {
                                    set2 = createSet(Color.YELLOW);
                                    data2.addDataSet(set2);
                                }

                                if (set3 == null) {
                                    set3 = createSet(Color.parseColor("#FFA500"));
                                    data3.addDataSet(set3);
                                }


                                if (set4 == null) {
                                    set4 = createSet(Color.GREEN);
                                    data4.addDataSet(set4);
                                }

                                LineDataSet setset = null;

                                if (shows1) {
                                    etiqueta++;
                                    data.addXValue(String.valueOf(etiqueta));
                                    data.addEntry(new Entry(Transforma(sensor0), set.getEntryCount()), 0);

                                    setset = set;
                                }

                                if (shows2) {
                                    etiqueta++;
                                    data2.addXValue(String.valueOf(etiqueta));
                                    data2.addEntry(new Entry(Transforma(sensor1), set2.getEntryCount()), 1);

                                    setset = set2;
                                }

                                if (shows3) {
                                    etiqueta++;
                                    data3.addXValue(String.valueOf(etiqueta));
                                    data3.addEntry(new Entry(Transforma(sensor2), set3.getEntryCount()), 2);

                                    setset = set3;
                                }

                                if (shows4) {
                                    data4.addXValue(String.valueOf(etiqueta));
                                    data4.addEntry(new Entry(Transforma(sensor3), set4.getEntryCount()), 3);
                                    setset = set4;
                                }


                                //******************************
                                chart.notifyDataSetChanged();
                                chart.setVisibleXRange(1, 5);
                                chart.moveViewToX(setset.getEntryCount() - 6);
                            }
                        }
                        //******************************************
                        //******************************************


                        break;
                }
            }
        };


        //write method
        public void write(String input) {
            byte[] msgBuffer = input.getBytes();           //converts entered String into bytes
            try {
                mmOutStream.write(msgBuffer);                //write bytes over BT connection via outstream
            } catch (IOException e) {
                //if you cannot write, close the application
                Toast.makeText(getBaseContext(), "Connection Failure", Toast.LENGTH_LONG).show();
                finish();

            }
        }
    }
}