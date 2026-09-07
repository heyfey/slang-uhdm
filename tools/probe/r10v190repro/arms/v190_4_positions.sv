// r10v190 arm 4 — THE OTHER CLONE POSITIONS AND THE CONSUMPTION AXIS.
// One ranged typedef with a parameter bound is used at EVERY clone position
// earlier passes own — a function formal, a function return, a body local, an
// unpacked-array element, a struct member, a port, a cast, a variable — AND as
// an enum base.  Only the enum-base cell may move; anything else moving is an
// over-wide law.  The typedef is also declared with NO enum over it at all
// (unconsumed by this pass's site) to prove the gate never fires there.
package pv4_190;
  parameter integer QW = 19;

  typedef bit [QW-1 : 0] tq;                  // used everywhere below
  typedef bit [QW-2 : 0] tq_noenum;           // NEVER an enum base

  typedef enum tq { q_a = 0, q_b = 1 } eq;    // the ONLY cell this pass owns

  typedef struct packed { tq f0; bit [QW-3:0] f1; } sq;   // struct member
  typedef tq aq [3];                                       // unpacked array

  function automatic tq f_ret(input tq arg_formal);        // formal + return
    tq body_local;
    tq_noenum other_local;
    body_local  = arg_formal;
    other_local = '0;
    return body_local;
  endfunction

  tq        pkg_var;
  tq_noenum pkg_var_noenum;
  sq        pkg_struct;
  aq        pkg_arr;
endpackage

module v190_4_positions
  import pv4_190::*;
  (input tq port_in, output tq port_out);
  tq        mv;
  tq_noenum mv2;
  eq        ev;
  sq        sv;
  aq        av;
  always_comb begin
    mv  = pv4_190::f_ret(port_in);
    mv2 = '0;
    ev  = q_b;
    sv  = '{f0: mv, f1: '0};
    av  = '{default: '0};
  end
  assign port_out = tq'(mv);                  // cast position
endmodule
