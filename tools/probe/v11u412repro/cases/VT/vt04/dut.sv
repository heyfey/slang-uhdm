// § modKwlessTypeParamDropped412
module sub #(type T = int) (input logic [7:0] a, output logic [7:0] b);
  localparam int W = $bits(T);
  assign b = a + W;
endmodule
module top(input logic [7:0] i, output logic [7:0] o1, output logic [7:0] o2);
  sub u1(.a(i), .b(o1));
  sub #(.T(shortint)) u2(.a(i), .b(o2));
endmodule
