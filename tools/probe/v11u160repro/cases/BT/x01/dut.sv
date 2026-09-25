// § bodyTypeParamDefaultBound160
module top (input logic [15:0] d, output logic [15:0] o);
  localparam type my_t = logic [7:0];
  my_t [1:0] arr;
  assign arr = d;
  assign o = arr;
endmodule
