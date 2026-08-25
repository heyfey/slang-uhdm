// v85 adversarial arm A9 — can the OV suppression fire while the emitted range
// STILL names the overridden parameter?  (would be a dropped stamp golden keeps)
package y85_pkg;
  parameter int AddrW = 12;
  parameter int Depth = 8;
endpackage
module y85_a ();
  import y85_pkg::*;
  parameter int AddrW = 4;
  parameter int Depth = 4;
  typedef logic [AddrW-1:0] tw_t;
  localparam logic [$clog2(AddrW)-1:0] E1 = 3;   // bound inside a sys call
  localparam tw_t                      E2 = 3;   // bound on a typedef
  localparam logic [AddrW-1:0][Depth-1:0] E3 = 0;
  localparam logic [(AddrW > 2 ? AddrW : 2)-1:0] E4 = 3;
  localparam logic [y85_pkg::AddrW-1:0] E5 = 3;  // QUALIFIED read of the pkg one
  localparam logic [AddrW-1:0] E6 [0:1] = '{3,3};
  logic [AddrW-1:0] n1;
endmodule
module va9_ovedge85 ();
  y85_a #(.AddrW(9), .Depth(5)) u_a ();
  y85_a                          u_b ();
endmodule
