// § bitsConcatLastResolvesAbstain421v
module top #(parameter w_p = 4) (input logic [3:0] a, input logic [w_p-1:0] b, output logic [7:0] o);
  localparam W = $bits({a, b});
  assign o = W;
endmodule
