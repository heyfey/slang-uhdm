// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; } c_t;
  localparam c_t C = '0;
endpackage
module dut #(parameter pk::c_t P = '0) (input logic clk, output logic [7:0] o);
  always_ff @(posedge clk) o <= P.u.a;
endmodule
