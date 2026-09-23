// r11u104 arm r3 — EVERY OTHER HOME of the package-parameter fold site, where
// the seven digit flags now write the producer's digits and the reader width
// is NOT handed (the width is the net declaration's alone).  Each home reads
// the same seven shapes (the five UINT arms, the bare leaf, the name hop) into
// a NARROWER target than the parameter: a module localparam, a module
// parameter default, an instance override, a port connection, a written
// assign (def + elaborated view), an operand under a net-decl-assign, a
// select index, a procedural assignment, a function return, an if condition,
// a concatenation and an interface's net declaration.
package r3p;
  localparam longint BLB  = 9223372036854775807;
  localparam longint BADD = 4294967296 + 1;
  localparam longint BOR  = 4294967296 | 255;
  localparam longint BAND = 12884901888 & 8589934847;
  localparam longint BSHL = 2147483648 << 1;
  localparam longint BSHR = 8589934592 >> 1;
  localparam int     CNAM = BLB;
  localparam int     IB31 = 2147483648;
  localparam byte    YB200 = 200;
endpackage
interface r3ifc;
  wire [7:0] iBLB  = r3p::BLB;
  wire [7:0] iBADD = r3p::BADD;
  wire [7:0] iIB31 = r3p::IB31;
  wire [63:0] iBLB64 = r3p::BLB;
  wire [63:0] iBOR64 = r3p::BOR;
endinterface
module r3sub #(parameter int PI = r3p::BLB, parameter byte PB = r3p::BOR,
               parameter longint PL = r3p::BADD)
              (input logic [7:0] i8, input logic [63:0] i64, output logic [63:0] q);
  assign q = PI + PB + PL + i8 + i64;
endmodule
module r3_otherhomes104 (input logic [63:0] a, output logic [63:0] o);
  localparam int     L32BLB  = r3p::BLB;
  localparam byte    L8BADD  = r3p::BADD;
  localparam int     L32BOR  = r3p::BOR;
  localparam longint L64BLB  = r3p::BLB;
  localparam longint L64BSHL = r3p::BSHL;
  localparam longint L64CNAM = r3p::CNAM;
  localparam logic [15:0] L16YB = r3p::YB200;
  wire [63:0] q1, q2, q3;
  r3sub u1 (.i8(r3p::BLB), .i64(r3p::BADD), .q(q1));
  r3sub #(.PI(r3p::BADD), .PB(r3p::BLB), .PL(r3p::BSHL)) u2 (.i8(r3p::BOR), .i64(r3p::BSHR), .q(q2));
  r3sub #(.PL(r3p::IB31)) u3 (.i8(r3p::IB31), .i64(r3p::IB31), .q(q3));
  wire [7:0]  oBLB8  = r3p::BLB + 0;
  wire [63:0] oBADD64 = r3p::BADD + 0;
  wire [63:0] oBOR64 = r3p::BOR - 1;
  wire [7:0] aBLB8, aBOR8;
  wire [63:0] aBLB64, aBAND64;
  assign aBLB8 = r3p::BLB;
  assign aBOR8 = r3p::BOR;
  assign aBLB64 = r3p::BLB;
  assign aBAND64 = r3p::BAND;
  wire sel1 = a[r3p::BSHR >> 32];
  logic [7:0] pBLB8, pBADD8;
  logic [63:0] pBLB64, pBSHR64;
  always_comb begin
    pBLB8 = r3p::BLB;
    pBADD8 = r3p::BADD;
    pBLB64 = r3p::BLB;
    if (r3p::BSHR != 0) pBSHR64 = r3p::BSHR;
    else pBSHR64 = r3p::BAND;
  end
  function automatic logic [7:0] fBLB8(); return r3p::BLB; endfunction
  function automatic logic [63:0] fBOR64(); return r3p::BOR; endfunction
  wire [15:0] cat16 = {r3p::YB200[7:0], r3p::YB200[7:0]};
  wire [127:0] cat128 = {r3p::BLB, r3p::BADD};
  r3ifc ifc ();
  assign o = q1 ^ q2 ^ q3 ^ oBLB8 ^ oBADD64 ^ oBOR64 ^ aBLB8 ^ aBOR8 ^ aBLB64 ^
             aBAND64 ^ sel1 ^ pBLB8 ^ pBADD8 ^ pBLB64 ^ pBSHR64 ^ fBLB8() ^
             fBOR64() ^ cat16 ^ cat128[63:0] ^ L32BLB ^ L8BADD ^ L32BOR ^
             L64BLB ^ L64BSHL ^ L64CNAM ^ L16YB ^ ifc.iBLB ^ ifc.iBLB64 ^
             ifc.iBOR64 ^ ifc.iBADD ^ ifc.iIB31;
endmodule
