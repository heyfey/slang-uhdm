// § ifaceGenCaLhsUnbound275 — a generate-local net in an interface
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 6};
endpackage
interface ifc #(parameter p::cfg_t C = p::LIT) ();
  logic [31:0] y;
  if (1) begin : gi
    logic [31:0] q;
    assign q = C.n;
    assign y = q;
  end
endinterface
module dut (output logic [31:0] o);
  ifc u ();
  assign o = u.y;
endmodule
