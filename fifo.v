module fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input wire clk,
    input wire reset,
    input wire wr, //write enable
    input wire rd, //read enable
    input wire [DATA_WIDTH-1:0] w_data, //data to be written into fifo
    output wire [DATA_WIDTH-1:0] r_data, //data read from fifo
    output wire empty, //flag to indicate if fifo is empty
    output wire full //flag to indicate if fifo is full
);

    reg [DATA_WIDTH-1:0] mem[2**ADDR_WIDTH-1:0]; //memory element to store data
    reg [ADDR_WIDTH-1:0] w_ptr, r_ptr; //read and write pointers
    reg [ADDR_WIDTH:0] count; //tracks how many elements are present

    assign full = (count == 2**ADDR_WIDTH);
    assign empty = (count == 0);
    assign r_data = mem[r_ptr];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            w_ptr <= 0; r_ptr <= 0; count <= 0;
        end else begin
            if (wr && !full) begin //write logic
                mem[w_ptr] <= w_data;
                w_ptr <= w_ptr + 1;
                count <= count + 1;
            end
            if (rd && !empty) begin //read logic
                r_ptr <= r_ptr + 1;
                count <= count - 1;
            end
        end
    end
endmodule