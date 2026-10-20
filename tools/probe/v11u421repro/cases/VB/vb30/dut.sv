// § bitsConcatLastResolvesAbstain421v
module top #(parameter w_p = 4) (input logic [3:0] a, output logic [7:0] o);
  localparam W = $bits({a, w_p});
  assign o = W;
endmodule
