// r11u79 z5 — THE UNPACKED PACKAGE DECLARATION, ELEMENT SPELLING BY ELEMENT
// SPELLING AND DIMENSION BY DIMENSION.  r11v77 measured this table for the
// MODULE-side hoisted holder and found five element spellings and two
// dimension spellings the builder got wrong; the PACKAGE side is a different
// writer (`netlist->variables()` for isNet==false, a FLAT logic_net in
// `p->Nets()` for isNet==true), so it is measured here from scratch.  Every
// field read below is a COMPARED one: array_var::Compare reads Variables(),
// variables::Compare reads VpiAutomatic, expr::Compare reads VpiSize.
package pu;
  typedef struct packed { logic [7:0] x; logic [7:0] y; } sl_t;   // ALL-LOGIC
  typedef struct packed { int x; logic [7:0] y; }         si_t;   // an INT member
  typedef union  packed { logic [7:0] a; logic [7:0] b; } un_t;
  typedef enum logic [1:0] { EA, EB }                     en_t;

  logic [7:0] u_vlog  [0:1];   // variable, logic element
  wire  [7:0] u_nlog  [0:1];   // NET,      logic element
  sl_t        u_vsl   [0:1];   // variable, all-logic struct element
  wire  sl_t  u_nsl   [0:1];   // NET,      all-logic struct element
  si_t        u_vsi   [0:1];   // variable, int-member struct element
  wire  si_t  u_nsi   [0:1];
  un_t        u_vun   [0:1];
  wire  un_t  u_nun   [0:1];
  en_t        u_ven   [0:1];
  wire  en_t  u_nen   [0:1];
  int         u_vint  [0:1];
  bit   [7:0] u_vbit  [0:1];
  real        u_vreal [0:1];
  string      u_vstr  [0:1];

  logic [7:0] u_2d [0:1][0:2];          // TWO unpacked dimensions
  logic [7:0] u_sh [2];                 // the [N] shorthand
  typedef logic [7:0] arr_t [0:1];
  arr_t       u_td;                     // a TYPEDEF'd unpacked array
  logic [7:0] u_dyn [];                 // a DYNAMIC array
  logic [7:0] u_q   [$];                // a QUEUE
  logic [7:0] u_as  [string];           // an ASSOCIATIVE array
endpackage

module dut (output logic [31:0] o);
  import pu::*;
  assign o = {24'd0, u_vlog[0]} ^ {24'd0, u_nlog[0]} ^ {16'd0, u_vsl[0]}
           ^ {16'd0, u_nsl[0]}  ^ u_vint[0]         ^ {24'd0, u_2d[0][0]}
           ^ {24'd0, u_sh[0]}   ^ {24'd0, u_td[0]};
endmodule
