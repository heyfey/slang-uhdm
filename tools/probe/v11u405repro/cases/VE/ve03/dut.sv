// § tpCastBeforeTpListed405
module top #(parameter type T = logic [3:0], parameter int W = $bits(T'(0))) (output logic [W-1:0] o);
  assign o = '1;
endmodule
