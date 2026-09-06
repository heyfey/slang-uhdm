// r10vearl110 arm v3 -- SHAPE FACES: interface arrays vs struct arrays vs plain
// arrays, member steps ONE and TWO deep, +: / -: / [l:r] / bit-select tails,
// genvar / constant / expression receiver indices -- all at generate depth 1
// where the patch's gate is OPEN.
package pv3;
  parameter int unsigned PW = 6;
  typedef struct packed { logic [31:0] inner; } deep_t;
  typedef struct packed { logic [31:0] fld; deep_t sub; } c_t;
endpackage

interface v3_if #(parameter int unsigned W = 32) ();
  logic [W-1:0] wline;
  modport mp (input wline);
endinterface

module v3_shape #(parameter int unsigned NCH = 3) (
  input  pv3::c_t   sarr [NCH],      // unpacked ARRAY OF STRUCTS (the head shape)
  input  logic [31:0] parr [NCH],    // PLAIN unpacked array
  input  pv3::c_t   flat,            // a NON-array struct receiver
  output logic [31:0] oz
);
  localparam int unsigned RA = 9;
  localparam int unsigned RB = 3;
  v3_if ifa [NCH] ();                // an INTERFACE ARRAY
  logic [31:0] s1,s2,s3,s4,s5,s6,s7,s8,s9,sa,sb,sc,sd,se;

  for (genvar k = 0; k < NCH; k++) begin : blk_k
    // c1  array-of-struct, ONE member step, +: tail          (the head shape)
    assign s1 = {26'b0, sarr[k].fld[0+:(RA-RB)]};
    // c2  array-of-struct, TWO member steps deep, +: tail
    assign s2 = {26'b0, sarr[k].sub.inner[0+:(RA-RB)]};
    // c3  array-of-struct, one step, -: tail with an arithmetic BASE
    assign s3 = {29'b0, sarr[k].fld[(RA-1)-:RB]};
    // c4  array-of-struct, one step, PLAIN [l:r] part select
    assign s4 = {26'b0, sarr[k].fld[(RA-1):RB]};
    // c5  array-of-struct, one step, BIT SELECT tail with arithmetic index
    assign s5 = {31'b0, sarr[k].fld[(RA-RB)]};
    // c6  INTERFACE ARRAY element, +: tail
    assign s6 = {26'b0, ifa[k].wline[0+:(RA-RB)]};
    // c7  PLAIN unpacked array element, no member step, +: tail
    assign s7 = {26'b0, parr[k][0+:(RA-RB)]};
    // c8  CONSTANT receiver index instead of the genvar
    assign s8 = {26'b0, sarr[1].fld[0+:(RA-RB)]};
    // c9  EXPRESSION receiver index
    assign s9 = {26'b0, sarr[k+1-1].fld[0+:(RA-RB)]};
    // ca  a NON-array struct receiver (dotted base, no bit_select head)
    assign sa = {26'b0, flat.fld[0+:(RA-RB)]};
    // cb  a non-array struct, TWO steps deep
    assign sb = {26'b0, flat.sub.inner[0+:(RA-RB)]};
    // cc  arithmetic in BOTH halves at once
    assign sc = {26'b0, sarr[k].fld[(RA-RB)-:(RA-RB)]};
    // cd  a PACKAGE parameter leaf in the half
    assign sd = {27'b0, sarr[k].fld[0+:(pv3::PW-1)]};
    // ce  the GENVAR in the width half beside a localparam
    assign se = {26'b0, sarr[k].fld[0+:(RA-RB)]} ^ {28'b0, sarr[k].fld[(k*RB)+:4]};
  end
  assign oz = s1^s2^s3^s4^s5^s6^s7^s8^s9^sa^sb^sc^sd^se;
endmodule
