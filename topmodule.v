`timescale 1ns / 1ps

module top_uart (
    input wire clk,
    input wire reset,
    input wire rx, //Receive data line
    output wire tx, //Transmission data line
    output wire rx_done_tick, // indicates all data bits received
    output wire tx_done_tick, // indicates all data bits transmitted
    output wire fifo_full, //flag to indicate if fifo is full
    output wire fifo_empty //flag to indicate if fifo is empty
);

    wire tick; //tick signal
    wire [7:0] rx_data; //received data
    wire [7:0] tx_data; //transmitted data

    wire wr_en; //write enable
    wire rd_en; //read enable

    // Baud rate generator
    baud_gen #(326) baud_unit (
        .clk(clk),
        .reset(reset),
        .tick(tick)
    );

    // Receiver
    uart_rx rx_unit (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .s_tick(tick),
        .rx_done_tick(rx_done_tick),
        .dout(rx_data)
    );

    // FIFO buffer
    fifo #(8, 4) fifo_unit (
        .clk(clk),
        .reset(reset),
        .wr(rx_done_tick),         // write when rx data received
        .rd(rd_en),                // read when ready to transmit
        .w_data(rx_data),
        .r_data(tx_data),
        .empty(fifo_empty),
        .full(fifo_full)
    );

    reg tx_start_reg = 0;
    reg [1:0] tx_state = 0;

    assign rd_en = (tx_state == 0) && !fifo_empty;

    // Transmitter
    uart_tx tx_unit (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start_reg),
        .s_tick(tick),
        .din(tx_data),
        .tx_done_tick(tx_done_tick),
        .tx(tx)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tx_start_reg <= 0;
            tx_state <= 0;
        end else begin
            case (tx_state)
                0: if (!fifo_empty) tx_state <= 1;
                1: begin
                    tx_start_reg <= 1;
                    tx_state <= 2;
                end
                2: begin
                    tx_start_reg <= 0;
                    if (tx_done_tick)
                        tx_state <= 0;
                end
            endcase
        end
    end

endmodule