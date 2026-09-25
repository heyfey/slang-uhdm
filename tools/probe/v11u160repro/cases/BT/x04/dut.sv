// § bodyTypeParamDefaultBound160
module top #(parameter type T = logic [3:0]) (input logic [7:0] d, output logic [7:0] o);
  localparam type w_t = T;
  w_t [1:0] arr;
  assign arr = d;
  assign o = arr;
endmodule
