// r11v69 w8 — THE $unit AND PACKAGE NAMESAKE.  Our `genCaLhsGenLocal113` walk
// climbs PAST the top InstanceBody into the compilation unit; golden's
// `bindVariable` recurses through `scope->VpiParent()` and the DESIGN carries no
// `Variables()`.  Where the two disagree the gate fires although golden shares.
// Row `gc` has no namesake anywhere and is the control golden must SHARE.
package q;
  logic [15:0] pkgname;
endpackage

package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 300};
endpackage

logic [7:0] unitname;          // $unit-scope namesake, 8 bits

module dut #(parameter p::cfg_t CFG = p::LIT)
  (input logic a_i, output logic [31:0] o_u, o_p, o_c);
  import q::pkgname;
  if (1) begin : gu
    logic [31:0] unitname;     // gen-local, 32 bits, $unit namesake exists
    assign unitname = CFG.n;
    assign o_u = unitname;
  end
  if (1) begin : gp
    logic [31:0] pkgname;      // gen-local, package namesake exists
    assign pkgname = CFG.n;
    assign o_p = pkgname;
  end
  if (1) begin : gc
    logic [31:0] nowhere;      // no namesake anywhere -> golden SHARES
    assign nowhere = CFG.n;
    assign o_c = nowhere;
  end
endmodule
