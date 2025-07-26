module uart_rx (
    input wire clk,
    input wire reset,
    input wire rx, //data line
    input wire s_tick,  //tick_counter
    output reg rx_done_tick, //indicates all data bits received
    output reg [7:0] dout //data_out
);
    reg [3:0] s_reg; //to count s_tick
    reg [2:0] n_reg; //to count no of bits received
    reg [7:0] b_reg; //to store received data
    reg [1:0] state; //to track states(idle,start,data,stop)

    localparam [1:0]
        idle  = 2'b00,
        start = 2'b01,
        data  = 2'b10,
        stop  = 2'b11;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= idle;
            s_reg <= 0;
            n_reg <= 0;
            b_reg <= 0;
            rx_done_tick <= 0;
        end else begin
            rx_done_tick <= 0;
            case (state)
                idle:
                    if (~rx) begin //start bit becomes low
                        state <= start;
                        s_reg <= 0;
                    end
                start:
                    if (s_tick) begin
                        s_reg <= s_reg + 1;
                        if (s_reg == 7) begin //middle of start bit
                            state <= data;
                            s_reg <= 0;
                            n_reg <= 0;
                        end
                    end
                data:
                    if (s_tick) begin
                        s_reg <= s_reg + 1;
                        if (s_reg == 15) begin //middle of data bit
                            s_reg <= 0;
                            b_reg <= {rx, b_reg[7:1]};
                            if (n_reg == 7)
                                state <= stop; //all 8 bits transmitted
                            else
                                n_reg <= n_reg + 1;
                        end
                    end
                stop:
                    if (s_tick) begin
                        if (s_reg == 15) begin
                            state <= idle;
                            rx_done_tick <= 1;
                            dout <= b_reg;
                        end else
                            s_reg <= s_reg + 1;
                    end
            endcase
        end
    end
endmodule