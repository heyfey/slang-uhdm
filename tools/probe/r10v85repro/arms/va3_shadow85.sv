// v85 adversarial arm A3 — the vpiOverriden stamp: wildcard-import shadowing
// vs. not, overridden vs. not, folded range vs. symbolic range.
package s85_pkg;
  parameter int AddrW = 17;
  parameter int OtherW = 4;
endpackage
package t85_pkg;
  parameter int Unrelated = 3;
endpackage

// (1) shadowed: module-local overridden AddrW AND a wildcard import declaring AddrW
module s85_shadowed ();
  import s85_pkg::*;
  parameter int AddrW = 5;
  parameter int Bare  = 6;
  localparam logic [AddrW-1:0] SMask = 3;
  localparam logic [Bare-1:0]  BMask = 3;
  localparam logic [AddrW-1:0] SHead = ~(('h1 << 8) - 1'b1);
endmodule

// (2) NOT shadowed: same shape, import has no same-named member
module s85_plain ();
  import t85_pkg::*;
  parameter int AddrW = 5;
  localparam logic [AddrW-1:0] PMask = 3;
  localparam logic [AddrW-1:0] PHead = ~(('h1 << 8) - 1'b1);
endmodule

// (3) no import at all
module s85_noimp ();
  parameter int AddrW = 5;
  localparam logic [AddrW-1:0] NMask = 3;
endmodule

// (4) explicit (non-wildcard) import of the same name
module s85_expimp ();
  import s85_pkg::AddrW;
  parameter int Wid = 5;
  localparam logic [Wid-1:0] EMask = 3;
endmodule

module va3_shadow85 ();
  s85_shadowed #(.AddrW(9), .Bare(7)) u_sh ();
  s85_shadowed                        u_sh_def ();
  s85_plain    #(.AddrW(9))           u_pl ();
  s85_noimp    #(.AddrW(9))           u_ni ();
  s85_expimp   #(.Wid(9))             u_ei ();
endmodule
