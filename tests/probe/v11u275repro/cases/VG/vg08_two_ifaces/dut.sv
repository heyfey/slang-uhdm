// § ifaceGenCaLhsUnbound275 — two interface instances with overrides
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 6};
  localparam cfg_t LIT2 = '{n: 7};
endpackage
interface ifc #(parameter p::cfg_t C = p::LIT) ();
  logic [31:0] i_gen;
  if (1) begin : gi
    assign i_gen = C.n;
  end
endinterface
module dut (output logic [31:0] o);
  ifc u ();
  ifc #(.C(p::LIT2)) w ();
  assign o = u.i_gen + w.i_gen;
endmodule
