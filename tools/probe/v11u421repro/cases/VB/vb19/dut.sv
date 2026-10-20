// § bitsConcatLastResolvesAbstain421v
module c (input logic [3:0] a, b, output logic [7:0] o);
  localparam W = $bits({a, b});
  assign o = W;
endmodule
module top (input logic [3:0] a, b, output logic [7:0] o1, o2); c u(a, b, o1); c v(b, a, o2); endmodule
