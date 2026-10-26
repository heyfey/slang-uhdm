// § modTdRangeClogKeeps434
module top #(parameter W = 8) (input logic [2:0] a, output logic [2:0] o);
  typedef logic [$clog2(W)-1:0] t;
  t w;
  assign w = a;
  assign o = w;
endmodule
