// r10buvm18 GRID — golden measurement of the parameter TYPESPEC for every
// declared-type / home / initializer shape.  MEASUREMENT ONLY.
package gp;
  parameter int NB = 28;
  parameter NBU = 28;                // UNTYPED bound parameter
  typedef bit [NBU-1:0] bflagu_t;
  typedef bit   [NB-1:0] bflag_t;   // bit vector typedef, PARAMETER bound
  typedef bit   [7:0]    b8_t;      // bit vector typedef, LITERAL bound
  typedef logic [7:0]    l8_t;      // logic vector typedef
  typedef logic [NB-1:0] lflag_t;   // logic vector typedef, PARAMETER bound
  typedef int            i_t;       // int typedef
  typedef byte           by_t;      // byte typedef
  typedef bit            b1_t;      // scalar bit typedef
  typedef logic          l1_t;      // scalar logic typedef
  typedef enum bit [1:0] { EA, EB } e_t;
  typedef struct packed { bit [3:0] a; bit [3:0] b; } s_t;
  typedef bflag_t        bflag2_t;  // typedef OF typedef

  parameter  bflagu_t P_SHIFTU  = (1<<8);
  parameter  bflag_t  P_SHIFT   = (1<<8);
  parameter  bflag_t  P_LIT     = 5;
  parameter  bflag_t  P_SIZED   = 8'hAA;
  parameter  bflag_t  P_OTHER   = P_SHIFT;
  parameter  bflag_t  P_EXPR    = P_SHIFT + 1;
  parameter  bflag_t  P_CAST    = bflag_t'(3);
  parameter  bflag_t  P_CONCAT  = {4'h1, 4'h2};
  localparam bflag_t  LP_SHIFT  = (1<<3);
  parameter  b8_t     P_B8      = 8'h0F;
  parameter  l8_t     P_L8      = 8'h0F;
  parameter  lflag_t  P_LFLAG   = (1<<5);
  parameter  i_t      P_I       = 7;
  parameter  by_t     P_BY      = 3;
  parameter  b1_t     P_B1      = 1'b1;
  parameter  l1_t     P_L1      = 1'b1;
  parameter  e_t      P_E       = EA;
  parameter  s_t      P_S       = 8'h12;
  parameter  bflag2_t P_TDTD    = 2;
  parameter  bit [7:0] P_BUILTIN = 8'h11;
  parameter  logic [7:0] P_BUILTINL = 8'h11;
  parameter  int      P_INT     = 4;
  parameter           P_UNTYPED = 9;
endpackage

package cp;
  typedef bit [7:0] cb_t;
  class C;
    localparam cb_t CLS_LP = 8'h5;
  endclass
endpackage

parameter gp::bflag_t UNIT_Q = (1<<7);   // $unit home, qualified pkg typedef

module m #(parameter gp::bflag_t MP = (1<<2)) ();
  parameter  gp::bflag_t MB   = (1<<1);
  localparam gp::bflag_t ML   = (1<<0);
  parameter  gp::l8_t    MQL  = 8'h07;   // module home, QUALIFIED logic typedef
  parameter  gp::i_t     MQI  = 7;       // module home, QUALIFIED int typedef
  typedef bit   [3:0] loc_t;
  typedef logic [3:0] locl_t;
  typedef int         loci_t;
  parameter  loc_t       MLOC = 4'h3;    // module home, OWN bit typedef
  parameter  locl_t      MLOCL = 4'h3;   // module home, OWN logic typedef
  parameter  loci_t      MLOCI = 3;      // module home, OWN int typedef
  if (1) begin : g
    parameter  gp::bflag_t GP2 = 1;
    localparam loc_t       GL  = 4'h2;
  end
endmodule

module mi ();
  import gp::*;
  parameter  bflag_t MIU = (1<<6);       // module home, UNQUALIFIED imported typedef
endmodule

module top ();
  m #(.MP(8'h40)) u ();
endmodule
