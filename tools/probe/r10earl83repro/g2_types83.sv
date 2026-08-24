// r10earl83 arm 2 — THE CAST-TYPE x OPERAND MATRIX, all in the ONE context
// this pass's law claims: an ELABORATED port High_conn.  GOLDEN answers what
// width, what tag and what span the reduced constant carries for each written
// cast type, and which shapes it REFUSES to reduce.  MEASUREMENT ONLY.
package p83;
  parameter int PP = 6;
  typedef logic [7:0] byte_t;
  typedef enum logic [2:0] { E0 = 3'h0, E5 = 3'h5 } e_t;
endpackage

module c83 (input logic [63:0] a, output logic [63:0] y);
  assign y = ~a;
endmodule

module g2_types83;
  import p83::*;
  localparam int LP = 5;
  localparam logic [3:0] LB = 4'h7;
  logic [63:0] n0;
  logic [63:0] o [0:39];
  logic [63:0] acc;

  // ---- CAST TYPE, literal operand -------------------------------------
  c83 t00 (.a(integer'(0)),   .y(o[0]));
  c83 t01 (.a(int'(5)),       .y(o[1]));
  c83 t02 (.a(byte'(300)),    .y(o[2]));
  c83 t03 (.a(shortint'(70000)), .y(o[3]));
  c83 t04 (.a(longint'(5)),   .y(o[4]));
  c83 t05 (.a(bit'(3)),       .y(o[5]));
  c83 t06 (.a(logic'(3)),     .y(o[6]));
  c83 t07 (.a(4'(9)),         .y(o[7]));
  c83 t08 (.a(8'(300)),       .y(o[8]));
  c83 t09 (.a(byte_t'(300)),  .y(o[9]));
  c83 t10 (.a(64'(e_t'(5))),  .y(o[10]));
  c83 t11 (.a(64'(signed'(-3))),   .y(o[11]));
  c83 t12 (.a(64'(unsigned'(-3))), .y(o[12]));
  c83 t13 (.a(time'(7)),      .y(o[13]));
  c83 t14 (.a(integer'(4'hb)),   .y(o[14]));
  c83 t15 (.a(integer'(8'sd9)),  .y(o[15]));
  c83 t16 (.a(integer'(-3)),     .y(o[16]));
  c83 t17 (.a(bit'(1'b1)),       .y(o[17]));
  c83 t18 (.a(integer'(64'hFFFF_FFFF_FFFF_FFFF)), .y(o[18]));

  // ---- OPERAND SHAPE, one cast type -----------------------------------
  c83 s00 (.a(integer'(LP)),        .y(o[20]));  // module localparam
  c83 s01 (.a(integer'(p83::PP)),   .y(o[21]));  // package parameter
  c83 s02 (.a(integer'(LB)),        .y(o[22]));  // based localparam
  c83 s03 (.a(integer'(LP + 2)),    .y(o[23]));  // expression
  c83 s04 (.a(integer'(n0)),        .y(o[24]));  // A NET: NOT constant
  c83 s05 (.a(integer'(n0[3:0])),   .y(o[25]));  // a net select
  c83 s06 (.a(byte_t'({ << bit { 8'h5a } })), .y(o[26])); // a STREAM (buvm29)
  c83 s07 (.a(integer'(E5)),        .y(o[27]));  // an enum constant
  c83 s08 (.a(integer'($clog2(9)))  , .y(o[28])); // a system call
  c83 s09 (.a(integer'(integer'(4))), .y(o[29])); // a NESTED cast
  c83 s10 (.a(integer'(LP > 0 ? 3 : 4)), .y(o[30])); // a ternary
  c83 s11 (.a(integer'(1'bx)),      .y(o[31]));  // an X literal
  c83 s12 (.a(integer'("ab")),      .y(o[32]));  // a string literal

  always_comb begin
    acc = 64'd0;
    for (int i = 0; i < 40; i++) acc = acc ^ o[i];
  end
  assign n0 = acc;
endmodule
