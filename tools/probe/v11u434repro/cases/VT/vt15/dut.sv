// § modTdRangeClogKeeps434
module top #(parameter W = 8) (input logic [7:0] a, output logic [2:0] o);
  typedef logic [$clog2($bits(a))-1:0] t;
  t x;
  assign x = a[2:0];
  assign o = x;
endmodule
