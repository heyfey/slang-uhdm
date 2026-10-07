// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; } c_t;
endpackage
interface ifc #(parameter pk::c_t P = 24'h010203); logic [7:0] s; assign s = P.u.a; endinterface
module dut(output logic [7:0] o); ifc #(.P(24'h040506)) u(); assign o = u.s; endmodule
