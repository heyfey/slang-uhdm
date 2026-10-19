// § modKwlessTypeParamDropped412
module sub #(parameter W = 4, type T = logic [W-1:0]) (input T a, output T b);
  assign b = ~a;
endmodule
module top(input logic [5:0] i, output logic [5:0] o);
  sub #(.W(6)) u(.a(i), .b(o));
endmodule
