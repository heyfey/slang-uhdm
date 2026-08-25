// v85 adversarial arm A2 — the same head shape in every HOME, with parameter
// kinds (overridden / not / package / gen-scope) and 1..3 instances.
package q85b_pkg;
  parameter int PKGW = 5;
  parameter int AddrW = 9;
  localparam logic [15:0] PMASK = ~(('h1 << PKGW) - 1'b1);
  localparam int PSH = ('h1 << PKGW);
endpackage

interface va2_if85 #(parameter int IW = 4) ();
  localparam logic [15:0] IMASK = ~(('h1 << IW) - 1'b1);
  localparam int          ISH   = ('h1 << IW);
endinterface

module va2_child85 #(
  parameter int AddrW = 17,
  parameter int WordsBitWidth = 8,
  parameter int NOTOV = 3
) ();
  localparam logic [AddrW-1:0] PageAddrMask = ~(('h1 << WordsBitWidth) - 1'b1);
  localparam logic [AddrW-1:0] NotOvMask    = ~(('h1 << NOTOV) - 1'b1);
  localparam int               PlainSh      = ('h1 << WordsBitWidth);
  localparam logic [q85b_pkg::AddrW-1:0] PkgRangeMask = ~(('h1 << WordsBitWidth) - 1'b1);
endmodule

module va2_homes85 ();
  parameter int TOPW = 6;
  genvar gi;
  // gen-for home
  for (gi = 0; gi < 2; gi++) begin : g_loop
    localparam logic [15:0] GMASK = ~(('h1 << (gi + 3)) - 1'b1);
    localparam int          GSH   = ('h1 << (gi + 2));
    va2_child85 #(.AddrW(11), .WordsBitWidth(gi + 2)) u_gc ();
  end
  // gen-if home
  if (TOPW > 4) begin : g_yes
    localparam logic [15:0] YMASK = ~(('h1 << TOPW) - 1'b1);
  end else begin : g_no
    localparam logic [15:0] NMASK = ~(('h1 << TOPW) - 1'b1);
  end

  va2_child85 #(.AddrW(17), .WordsBitWidth(8))  u_a ();
  va2_child85 #(.AddrW(17), .WordsBitWidth(4))  u_b ();
  va2_child85                                   u_c ();
  va2_if85 #(.IW(7)) u_if ();
endmodule
