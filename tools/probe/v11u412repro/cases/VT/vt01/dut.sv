// § modKwlessTypeParamDropped412
module sub #(type T = logic [3:0]) (input T a, output T b);
  assign b = a;
endmodule
module top(input logic [7:0] i, output logic [7:0] o);
  sub #(.T(logic [7:0])) u(.a(i), .b(o));
endmodule
