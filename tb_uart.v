`timescale 1ns / 1ps

module tb_top_uart;

    reg clk = 0;
    reg reset;

    reg rx;
    wire tx;
    wire fifo_full, fifo_empty;
    wire rx_done_tick, tx_done_tick;

    reg [7:0] test_data [0:3];
    reg [1:0] data_index = 0;

    // Instantiate DUT
    top_uart uut (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .tx(tx),
        .rx_done_tick(rx_done_tick),
        .tx_done_tick(tx_done_tick),
        .fifo_full(fifo_full),
        .fifo_empty(fifo_empty)
    );

    // Generate 50 MHz clock (20 ns period)
    always #10 clk = ~clk;

    integer i;

    // Send 1 byte using 8N1 UART protocol
    task uart_write_byte(input [7:0] data);
        begin
            rx = 0;         // Start bit
            #(326 * 20);

            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];
                #(326 * 20);
            end

            rx = 1;         // Stop bit
            #(326 * 20);
        end
    endtask

    initial begin
        test_data[0] = 8'h55; // 0101_0101
        test_data[1] = 8'hAA; // 1010_1010
        test_data[2] = 8'h0F; // 0000_1111
        test_data[3] = 8'hF0; // 1111_0000

        rx = 1;  // Idle line
        reset = 1;
        #100;
        reset = 0;

        for (data_index = 0; data_index < 4; data_index = data_index + 1) begin
            uart_write_byte(test_data[data_index]);
            #1000000; // Wait sufficient time for processing
        end

        #2000000;
        $finish;
    end

endmodule
