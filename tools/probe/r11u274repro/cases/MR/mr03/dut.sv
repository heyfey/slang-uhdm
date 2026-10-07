// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; } c_t;
  localparam c_t C = '0;
endpackage
module kid #(parameter pk::c_t P = 24'h010208) (input logic clk, output logic [7:0] o);
  logic [P.d-1:0] w;
  assign w = P.u.a;
  assign o = {P.u.b{1'b0}} | w[P.u.a+:2];
  function automatic logic [7:0] f(); return P.u.a + P.d; endfunction
  logic [7:0] z; always_comb z = f();
endmodule
module mid(input logic clk, output logic [7:0] o); kid u (.clk(clk), .o(o)); endmodule
module dut(input logic clk, output logic [7:0] o); mid m (.clk(clk), .o(o)); endmodule
