// r10earl110 arm g4 -- THE RECEIVER KINDS.  The base half of the path, varied,
// with the SAME param-arithmetic tail on every one of them.
package pk4_110;
  typedef struct packed { logic [15:0] lo; logic [15:0] hi; } inner_t;
  typedef struct packed { inner_t sub; logic [31:0] top; } outer_t;
endpackage

interface if4_110 ();
  logic [31:0] wline;
  modport mp (input wline);
endinterface

module g4_sink110 (input logic [31:0] pin4, output logic [31:0] pout4);
  assign pout4 = pin4;
endmodule

module g4_recv110 #(parameter int unsigned NW = 2) (
  input  pk4_110::outer_t oarr [NW],
  input  pk4_110::outer_t oflat,
  input  pk4_110::outer_t o2d [2][2],
  output logic [31:0]     rres
);
  localparam int unsigned RA = 9;
  localparam int unsigned RB = 4;
  if4_110 ifa [NW] ();
  logic [31:0] r1, r2, r3, r4, r5, r6, r7;
  // r1 array-of-struct element, member, indexed part select  (the head shape)
  assign r1 = { 27'b0, oarr[0].top[0+:(RA-RB)] };
  // r2 a PLAIN (non-array) struct port
  assign r2 = { 27'b0, oflat.top[0+:(RA-RB)] };
  // r3 a NESTED struct member chain
  assign r3 = { 27'b0, oflat.sub.lo[0+:(RA-RB)] };
  // r4 a nested chain UNDER an array element
  assign r4 = { 27'b0, oarr[1].sub.hi[0+:(RA-RB)] };
  // r5 a TWO-DIMENSIONAL unpacked array element
  assign r5 = { 27'b0, o2d[0][1].top[0+:(RA-RB)] };
  // r6 an INTERFACE-ARRAY element's member
  assign r6 = { 27'b0, ifa[0].wline[0+:(RA-RB)] };
  // r7 the same half in a PORT CONNECTION position
  g4_sink110 u_s4 (.pin4({27'b0, oarr[0].top[0+:(RA-RB)]}), .pout4(r7));
  assign rres = r1 ^ r2 ^ r3 ^ r4 ^ r5 ^ r6 ^ r7;
endmodule
