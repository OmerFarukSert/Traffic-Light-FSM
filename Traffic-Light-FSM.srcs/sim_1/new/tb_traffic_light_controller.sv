`timescale 1ns/1ps

module tb_traffic_light_controller();

    // Testbench Sinyalleri
    logic clk;
    logic reset;
    logic TAORB;
    logic [1:0] LA, LB;

    
    traffic_light_controller uut (
        .clk(clk),
        .reset(reset),
        .TAORB(TAORB),
        .LA(LA),
        .LB(LB)
    );

    
    always #5 clk = ~clk;

   
    initial begin
        
        clk = 0;
        reset = 1;
        TAORB = 1; // Başta A sokağında trafik var
        
        #15 reset = 0; // Resetten çıkış
        
        $display("--- Test Başlıyor: S0 (A-Green) ---");
        #20;
        
        // DURUM 1: Trafik B'ye geçiyor (TAORB = 0)
        // S0 -> S1 geçişi bekleniyor
        @(posedge clk);
        TAORB = 0;
        $display("Zaman %0t: Trafik B'ye kaydı. S0 -> S1 Geçişi bekleniyor...", $time);

        // DURUM 2: Sarı Işık Kontrolü (S1'de 5 clock bekleme)
        // S1 -> S2 geçişi için timer=5 olmalı
        wait(LA == 2'b01); // Yellow
        $display("Zaman %0t: S1 (Yellow) Aktif. 5 saniye sayılıyor...", $time);
        
        repeat(6) @(posedge clk); // 5 cycle + 1 geçiş için
        
        if (LB == 2'b00) // Green
            $display("Zaman %0t: BAŞARILI - S2'ye (B-Green) geçildi.", $time);
        else
            $display("Zaman %0t: HATA - S2'ye geçilemedi!", $time);

        #30;

        // DURUM 3: Trafik tekrar A'ya dönüyor (TAORB = 1)
        // S2 -> S3 geçişi bekleniyor
        @(posedge clk);
        TAORB = 1;
        $display("Zaman %0t: Trafik A'ya döndü. S2 -> S3 Geçişi bekleniyor...", $time);

        wait(LB == 2'b01); // Yellow
        $display("Zaman %0t: S3 (Yellow) Aktif. 5 saniye sayılıyor...", $time);

        repeat(6) @(posedge clk);

        if (LA == 2'b00) // Green
            $display("Zaman %0t: BAŞARILI - Tekrar S0'a dönüldü.", $time);
        
        #50;
        $display("--- Test Tamamlandı ---");
        $finish;
    end

endmodule