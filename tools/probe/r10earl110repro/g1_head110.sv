// r10earl110 arm g1 -- THE HEAD SHAPE, rebuilt from first principles.
// A module port that is an UNPACKED ARRAY OF STRUCTS, read inside a
// generate-for through `port[genvar].member[<half>]`.  Corpus original:
// Earlgrey_0_1 tlul_socket_m1.sv:97 and :105.
// Names here are deliberately unlike the corpus' and unlike each other.
package pk1_110;
  typedef struct packed {
    logic [15:0] tagfld;
    logic [7:0]  payl;
  } wire_t;
endpackage

module g1_head110 #(parameter int unsigned NPORT = 3) (
  input  pk1_110::wire_t inbus [NPORT],
  output logic [31:0]    shout
);
  localparam int unsigned WFULL = 8;
  localparam int unsigned WSUB  = $clog2(NPORT);
  logic [7:0] c1 [NPORT];
  logic [7:0] c2 [NPORT];
  logic [7:0] c3 [NPORT];
  logic       c4 [NPORT];
  logic [7:0] c5 [NPORT];
  logic [7:0] c6 [NPORT];
  for (genvar q = 0; q < NPORT; q++) begin : blk_q
    // c1  WIDTH half is param-param arithmetic  (the :97 cell)
    assign c1[q] = { {(8-(WFULL-WSUB)){1'b0}}, inbus[q].payl[0+:(WFULL-WSUB)] };
    // c2  BASE half is param-literal arithmetic, WIDTH a bare param (the :105 cell)
    assign c2[q] = { {(8-WSUB){1'b0}}, inbus[q].payl[WFULL-1 -: WSUB] };
    // c3  SIMPLE part select with a param-arith bound -- NOT this law's shape
    assign c3[q] = { 1'b0, inbus[q].payl[WFULL-1 : WSUB] };
    // c4  bit select with a bare param index
    assign c4[q] = inbus[q].payl[WSUB];
    // c5  bare-param WIDTH (the pre-existing elabHierSelWidthFold law)
    assign c5[q] = inbus[q].payl[0+:WFULL];
    // c6  literal-only halves -- must be byte-identical
    assign c6[q] = { 4'b0, inbus[q].payl[0+:4] };
  end
  assign shout = {c1[0], c2[0], c3[0], c5[0]};
endmodule
