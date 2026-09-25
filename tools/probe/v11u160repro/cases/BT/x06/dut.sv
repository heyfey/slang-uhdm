// § bodyTypeParamDefaultBound160
module top (input logic [7:0] d, output logic [7:0] o);
  localparam type my_t = enum logic [1:0] {A, B, C};
  my_t [3:0] arr;
  assign arr = d;
  assign o = arr;
endmodule
