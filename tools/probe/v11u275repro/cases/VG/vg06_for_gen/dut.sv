// § ifaceGenCaLhsUnbound275 — an interface for-generate assigning a scalar per iteration
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 6};
endpackage
interface ifc #(parameter p::cfg_t C = p::LIT) ();
  logic [31:0] a0, a1;
  for (genvar i = 0; i < 1; i++) begin : gf
    assign a0 = C.n;
  end
  assign a1 = C.n;
endinterface
module dut (output logic [31:0] o);
  ifc u ();
  assign o = u.a0 + u.a1;
endmodule
