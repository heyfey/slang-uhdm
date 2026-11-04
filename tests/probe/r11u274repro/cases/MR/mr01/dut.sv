// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; } c_t;
  localparam c_t C = '0;
endpackage
module kid #(parameter pk::c_t P = '0) (input logic clk, output logic [7:0] o);
  always_comb o = P.u.a ^ P.d;
endmodule
module dut(input logic clk, output logic [7:0] o, output logic [7:0] o2);
  kid k0 (.clk(clk), .o(o));
  kid #(.P(24'h010203)) k1 (.clk(clk), .o(o2));
endmodule
