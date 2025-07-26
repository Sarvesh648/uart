module uart_tx (
    input wire clk,
    input wire reset,
    input wire tx_start, //indicates start of transmission
    input wire s_tick, //tick counter
    input wire [7:0] din, //data_in
    output reg tx_done_tick, //indicates all data bits received
    output reg tx //data line
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
            tx <= 1'b1;
            tx_done_tick <= 0;
        end else begin
            tx_done_tick <= 0;
            case (state)
                idle:
                    if (tx_start) begin //transmission starts once tx_start is high
                        state <= start;
                        b_reg <= din;
                        s_reg <= 0;
                        tx <= 0;
                    end
                start:
                    if (s_tick) begin
                        if (s_reg == 15) begin
                            s_reg <= 0;
                            n_reg <= 0;
                            state <= data;
                        end else
                            s_reg <= s_reg + 1;
                    end
                data:
                    if (s_tick) begin
                        if (s_reg == 15) begin
                            s_reg <= 0;
                            tx <= b_reg[0]; //lsb of b_register is stored in tx line
                            b_reg <= b_reg >> 1;
                            if (n_reg == 7)
                                state <= stop; //all bits received
                            else
                                n_reg <= n_reg + 1;
                        end else
                            s_reg <= s_reg + 1;
                    end
                stop:
                    if (s_tick) begin
                        if (s_reg == 15) begin
                            state <= idle;
                            tx <= 1;
                            tx_done_tick <= 1; //data transmission is complete
                        end else
                            s_reg <= s_reg + 1;
                    end
            endcase
        end
    end
endmodule