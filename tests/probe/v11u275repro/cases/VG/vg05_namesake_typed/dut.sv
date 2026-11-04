// § ifaceGenCaLhsUnbound275 — a parent namesake with a struct type
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 6};
endpackage
interface ifc #(parameter p::cfg_t C = p::LIT) ();
  logic [31:0] i_gen;
  if (1) begin : gi
    assign i_gen = C.n;
  end
endinterface
module dut (output logic [31:0] o);
  p::cfg_t i_gen;
  assign i_gen = '{n: 1};
  ifc u ();
  assign o = u.i_gen + i_gen.n;
endmodule
