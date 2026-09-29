// § modStructMemberQualSpan214 — a CRLF file: the qualified bound in a struct member typedef inside an interface and inside a module generate block
package cfg;
  parameter int W = 6;
endpackage
interface ifc;
  typedef struct packed { logic [cfg::W-1:0] d; logic v; } it_t;
  it_t x;
endinterface
module top(output logic [6:0] o);
  ifc u();
  typedef struct packed { logic [cfg::W:0] d; } mt_t;
  mt_t m;
  assign m = '0;
  assign o = m;
  if (1) begin : g
    typedef struct packed { logic [cfg::W-2:0] e; } gt_t;
    gt_t gv;
  end
endmodule
