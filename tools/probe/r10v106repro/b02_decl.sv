// b02: DECLARATION shapes crossed with the same 'h1a init.
package b02_pkg;
  parameter               D_PLAIN  = 'h1a;
  parameter signed        D_SIGN   = 'h1a;
  parameter unsigned      D_UNS    = 'h1a;
  parameter [7:0]         D_RNG    = 'h1a;
  parameter signed [7:0]  D_SRNG   = 'h1a;
  parameter unsigned[7:0] D_URNG   = 'h1a;
  parameter int           D_INT    = 'h1a;
  parameter integer       D_INTG   = 'h1a;
  parameter longint       D_LINT   = 'h1a;
  parameter shortint      D_SINT   = 'h1a;
  parameter byte          D_BYTE   = 'h1a;
  parameter bit           D_BIT    = 'h1a;
  parameter logic         D_LOGIC  = 'h1a;
  parameter reg           D_REG    = 'h1a;
  parameter time          D_TIME   = 'h1a;
  parameter real          D_REAL   = 1.5;
  parameter shortreal     D_SREAL  = 1.5;
  parameter string        D_STR    = "s";
  parameter logic [3:0]   D_LV     = 'h1a;
  parameter bit signed    D_BS     = 'h1a;
  localparam              D_LPLAIN = 'h2b;
  localparam signed       D_LSIGN  = 'h2b;
  localparam int          D_LINT2  = 'h2b;
endpackage
module b02_top;
  import b02_pkg::*;
  initial $display(D_PLAIN, D_SIGN, D_RNG, D_INT, D_TIME, D_LPLAIN);
endmodule
