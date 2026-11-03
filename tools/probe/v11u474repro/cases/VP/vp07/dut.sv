// § elabParamClsScopedSubst474 (attack: driven variable and net, downstream)
package p; class S; localparam w = 4; endclass endpackage
module sub #(A = 8) (input logic [3:0] i, output logic [3:0] o);
  wire [A-1:0] n;
  logic [A-1:0] v;
  assign n = i;
  always_comb v = n + 1;
  assign o = v;
endmodule
module top(input logic [3:0] i, output logic [3:0] o); import p::*; sub #(.A(S::w)) u(.i(i), .o(o)); endmodule
