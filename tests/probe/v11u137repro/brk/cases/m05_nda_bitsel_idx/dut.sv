// § ndaLeftmostLeafElab139
module sub(input logic [3:0] a, input logic [1:0] i, output logic y);
  wire t = a[i] ^ a[0];
  assign y = t;
endmodule
module top(input logic [3:0] a, input logic [1:0] i, output logic y);
  sub u(.a(a), .i(i), .y(y));
endmodule
