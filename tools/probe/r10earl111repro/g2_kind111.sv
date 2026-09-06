// r10earl111 arm g2 -- THE DECLARED-TYPE MATRIX, one spelling per row, at the
// SAME select shape and the SAME scope, so exactly one axis moves.
// This arm is the law's MOVED-WRONG floor: golden stamps EVERY row, and this
// law admits only the two `int` rows, because a minted `int_typespec` is the
// only object it can produce that the judge reads as equal.
package pk2111;
  typedef logic [3:0] w_t;
  typedef int         i_t;
  typedef struct packed { logic [63:0] src; logic v; } h_t;
endpackage

module s2111 (input pk2111::h_t h_i, output logic [63:0] o);
  typedef int li_t;
  localparam int unsigned  A1  = 2;   // ADMIT   int_typespec sg=0
  localparam int           A2  = 2;   // ADMIT   int_typespec sg=1
  localparam int signed    A2b = 2;   // ADMIT   int_typespec sg=1
  localparam integer       A3  = 2;   // refuse  integer_typespec
  localparam byte          A4  = 2;   // refuse  byte_typespec
  localparam shortint      A5  = 2;   // refuse  short_int_typespec
  localparam longint       A6  = 2;   // refuse  long_int_typespec
  localparam bit           A7  = 1;   // refuse  bit_typespec rng=0
  localparam bit [3:0]     A8  = 2;   // refuse  bit_typespec rng=1
  localparam logic [7:0]   A9  = 2;   // refuse  logic_typespec rng=1
  localparam logic         A10 = 1;   // refuse  logic_typespec rng=0
  localparam pk2111::i_t   A11 = 2;   // refuse  int_typespec n='i_t' inst=pk
  localparam pk2111::w_t   A12 = 2;   // refuse  logic_typespec n='w_t'
  localparam li_t          A13 = 2;   // refuse  int_typespec n='li_t' alias
  localparam byte unsigned A14 = 2;   // refuse  byte_typespec
  localparam integer unsigned A15 = 2;// refuse  integer_typespec
  localparam               A16 = 2;   // refuse  IMPLICIT (see g5 c1)
  logic [63:0] r;
  for (genvar gi = 0; gi < 1; gi++) begin : gb
    assign r[ 1: 0] = h_i.src[0 +: A1];
    assign r[ 3: 2] = h_i.src[0 +: A2];
    assign r[ 5: 4] = h_i.src[0 +: A2b];
    assign r[ 7: 6] = h_i.src[0 +: A3];
    assign r[ 9: 8] = h_i.src[0 +: A4];
    assign r[11:10] = h_i.src[0 +: A5];
    assign r[13:12] = h_i.src[0 +: A6];
    assign r[15:14] = h_i.src[0 +: A7];
    assign r[17:16] = h_i.src[0 +: A8];
    assign r[19:18] = h_i.src[0 +: A9];
    assign r[21:20] = h_i.src[0 +: A10];
    assign r[23:22] = h_i.src[0 +: A11];
    assign r[25:24] = h_i.src[0 +: A12];
    assign r[27:26] = h_i.src[0 +: A13];
    assign r[29:28] = h_i.src[0 +: A14];
    assign r[31:30] = h_i.src[0 +: A15];
    assign r[33:32] = h_i.src[0 +: A16];
  end
  assign o = r;
endmodule

module g2_kind111;
  pk2111::h_t s;
  logic [63:0] oo;
  s2111 u (.h_i(s), .o(oo));
endmodule
