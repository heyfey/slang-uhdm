`define ID(x) (x)
`define OR2(x, y) ((x) | (y))
module top(input logic [7:0] b, output logic [7:0] y1, y2, y3);
  assign y1 = `ID(8'hFF     ) | b;
  assign y2 = `OR2(0     , b) | b;
  assign y3 = `ID(b) | 8'hFF     | b;
endmodule
