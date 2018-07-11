package com.kerdan.supercompara;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Handler;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;

public class splashActivity extends AppCompatActivity {

    // Splash screen timer
    private static int SPLASH_TIME_OUT = 1500;
    private boolean paso_url=false;


    private Intent SOUNDLOGOLOGO;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);






                new Handler().postDelayed(new Runnable() {

                    @Override
                    public void run() {
                        // This method will be executed once the timer is over
                        // Start your app main activity




                            Intent intent = new Intent(getApplicationContext(), DeviceList.class);
                            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                            startActivity(intent);
                            finish();





                    }
                }, SPLASH_TIME_OUT);


    }


    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
        //switch (requestCode) {
        //Toast.makeText(SplashActivity.this,"hola see",Toast.LENGTH_LONG).show();
        //}

        finish();
        startActivity(getIntent());

    }




}