// § ifaceGenCaLhsUnbound275 — CONTROL: the same read at the interface's own level keeps the copy
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 6};
endpackage
interface ifc #(parameter p::cfg_t C = p::LIT) ();
  logic [31:0] i_top;
  assign i_top = C.n;
endinterface
module dut (output logic [31:0] o);
  ifc u ();
  assign o = u.i_top;
endmodule
