module baud_gen #(parameter DVSR = 326)(
    input wire clk,
    input wire reset,
    output reg tick
);

    reg [8:0] count;  //used to count upto 325,then sets a tick

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 0;
            tick <= 0;
        end else if (count == DVSR - 1) begin
            count <= 0;
            tick <= 1; //at 325,1 tick is set
        end else begin
            count <= count + 1;
            tick <= 0;
        end
    end

endmodule