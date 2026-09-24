module top(input [1:0] idx, input [7:0] d, output [7:0] y);
  reg [7:0] mem [0:3];
  always @(*) mem[0] = d;
  wire [7:0] w = mem[idx];
  assign y = w;
endmodule
