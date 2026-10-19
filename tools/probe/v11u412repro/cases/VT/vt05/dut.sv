// § modKwlessTypeParamDropped412
module sub #(type T = logic [3:0], type U = T) (input T a, output U b);
  assign b = a;
endmodule
module top(input logic [3:0] i, output logic [3:0] o);
  sub u(.a(i), .b(o));
endmodule
