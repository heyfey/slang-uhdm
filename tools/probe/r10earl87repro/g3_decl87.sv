// r10earl87 arm g3 — DECLARATION KINDS x OVERRIDE STATE, all reached through
// one wildcard body import that collides on every name.
package pk3;
  localparam int          RA = 31;   // typed localparam
  parameter  int          RB = 32;   // typed parameter
  localparam              RC = 33;   // IMPLICIT (untyped) localparam
  localparam logic [7:0]  RD = 8'd34;// packed-range localparam
  localparam int          RE = 35;   // collides with a module LOCALPARAM
  localparam int          RF = 36;   // collides with nothing
endpackage

module d1 #(
  parameter int         RA = 1,
  parameter int         RB = 2,
  parameter             RC = 3,
  parameter logic [7:0] RD = 8'd4
) (output logic [7:0] o);
  import pk3::*;
  localparam int RE = 5;            // a LOCALPARAM cannot be overridden
  assign o = RA[7:0] + RB[7:0] + RC[7:0] + RD + RE[7:0] + RF[7:0];
endmodule

module top87 (output logic [7:0] o1, o2);
  // every kind overridden
  d1 #(.RA(7), .RB(8), .RC(9), .RD(8'd10)) u_all (.o(o1));
  // only the implicit one overridden
  d1 #(.RC(9))                             u_one (.o(o2));
endmodule
