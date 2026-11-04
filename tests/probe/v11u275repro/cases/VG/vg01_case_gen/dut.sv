// § ifaceGenCaLhsUnbound275 — an interface case-generate scope
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 6};
endpackage
interface ifc #(parameter p::cfg_t C = p::LIT, parameter int K = 1) ();
  logic [31:0] i_gen;
  case (K)
    1: begin : c1
      assign i_gen = C.n;
    end
    default: begin : cd
      assign i_gen = 0;
    end
  endcase
endinterface
module dut (output logic [31:0] o);
  ifc u ();
  assign o = u.i_gen;
endmodule
