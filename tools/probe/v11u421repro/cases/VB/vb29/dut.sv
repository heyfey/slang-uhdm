// § bitsConcatLastResolvesAbstain421v
module top (input logic [3:0] a, b, output logic [7:0] o);
  localparam W = $bits({a[1], b[2:0]});
  assign o = W;
endmodule
