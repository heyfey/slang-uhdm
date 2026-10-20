// § bitsConcatLastResolvesAbstain421v
module top (input logic [3:0] a, output logic [7:0] o);
  localparam W = $bits({4'b0, a});
  assign o = W;
endmodule
