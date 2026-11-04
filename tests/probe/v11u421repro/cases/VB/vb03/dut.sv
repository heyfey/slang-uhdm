// § bitsConcatLastResolvesAbstain421v
module top (input logic [3:0] a, b, output logic [7:0] o);
  localparam W = $bits({a, b});
  assign o = W;
endmodule
