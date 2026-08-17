// r10earl55 a1 — WHICH loc-less typespec does a TYPED param's REPLICATION
// fold carry?  Golden's Earlgrey head says `logic [NrHarts-1:0]` (N=1) and
// `logic [pinmux_reg_pkg::NMioPeriphOut-1:0]` (N=32) both get a LOC-LESS
// int_typespec (VpiValue = the replicated operand's width), while
// `logic [pinmux_reg_pkg::NDioPads-1:0]` (N=15) gets a LOC-LESS
// logic_typespec with the folded bounds.  This arm sweeps N so the split is
// MEASURED and not guessed at.  ELAB view: the module is instantiated.

package pk55;
  parameter int P1 = 1;
  parameter int P15 = 15;
  parameter int P32 = 32;
endpackage

module a1_earl55;
  localparam logic [1-1:0] LG1 = {1{1'b1}};
  localparam logic [2-1:0] LG2 = {2{1'b1}};
  localparam logic [3-1:0] LG3 = {3{1'b1}};
  localparam logic [4-1:0] LG4 = {4{1'b1}};
  localparam logic [5-1:0] LG5 = {5{1'b1}};
  localparam logic [7-1:0] LG7 = {7{1'b1}};
  localparam logic [8-1:0] LG8 = {8{1'b1}};
  localparam logic [9-1:0] LG9 = {9{1'b1}};
  localparam logic [15-1:0] LG15 = {15{1'b1}};
  localparam logic [16-1:0] LG16 = {16{1'b1}};
  localparam logic [17-1:0] LG17 = {17{1'b1}};
  localparam logic [31-1:0] LG31 = {31{1'b1}};
  localparam logic [32-1:0] LG32 = {32{1'b1}};
  localparam logic [33-1:0] LG33 = {33{1'b1}};
  localparam logic [63-1:0] LG63 = {63{1'b1}};
  localparam logic [64-1:0] LG64 = {64{1'b1}};
  localparam logic [65-1:0] LG65 = {65{1'b1}};
  // same widths, declared with a LITERAL msb instead of N-1
  localparam logic [0:0] LM1 = {1{1'b1}};
  localparam logic [14:0] LM15 = {15{1'b1}};
  localparam logic [31:0] LM32 = {32{1'b1}};
  // bit / reg / packed-struct-free variants at the three witness widths
  localparam bit [1-1:0] BT1 = {1{1'b1}};
  localparam reg [1-1:0] RG1 = {1{1'b1}};
  localparam bit [15-1:0] BT15 = {15{1'b1}};
  localparam reg [15-1:0] RG15 = {15{1'b1}};
  localparam bit [32-1:0] BT32 = {32{1'b1}};
  localparam reg [32-1:0] RG32 = {32{1'b1}};
  // UNTYPED (the § replFoldTs9 shape already modelled)
  localparam UT1 = {1{1'b1}};
  localparam UT15 = {15{1'b1}};
  localparam UT32 = {32{1'b1}};
  // int-declared
  localparam int IT32 = {32{1'b1}};
  // body operand WIDTH varied at a fixed total width of 32
  localparam logic [31:0] OW2 = {16{2'b10}};
  localparam logic [31:0] OW4 = {8{4'hf}};
  localparam logic [31:0] OW8 = {4{8'd3}};
  // the pinmux shape verbatim: a PACKAGE parameter as the count
  localparam logic [pk55::P1-1:0]  PG1  = {pk55::P1{1'b1}};
  localparam logic [pk55::P15-1:0] PG15 = {pk55::P15{1'b1}};
  localparam logic [pk55::P32-1:0] PG32 = {pk55::P32{1'b1}};
  // zero body (all-zero fold) at the three widths
  localparam logic [1-1:0] ZG1 = {1{1'b0}};
  localparam logic [15-1:0] ZG15 = {15{1'b0}};
  localparam logic [32-1:0] ZG32 = {32{1'b0}};
  sub55 #(.NR(1))  u_n1  (.o());
  sub55 #(.NR(15)) u_n15 (.o());
  sub55 #(.NR(32)) u_n32 (.o());
  psub55 #(.NR(1))  p_n1  (.o());
  psub55 #(.NR(15)) p_n15 (.o());
  psub55 #(.NR(32)) p_n32 (.o());
endmodule

// the rv_dm shape: a BODY localparam whose count is the module's own
// parameter, OVERRIDDEN at the instantiation.
module sub55 #(parameter int NR = 1) (output logic o);
  localparam logic [NR-1:0] SEL = {NR{1'b1}};
  assign o = SEL[0];
endmodule

// the dm_csrs COUNTEREXAMPLE: the same declaration in the PARAMETER PORT
// LIST, which golden gives the LOCATED logic_typespec.
module psub55 #(parameter int NR = 1,
               parameter logic [NR-1:0] SELP = {NR{1'b1}}) (output logic o);
  assign o = SELP[0];
endmodule
