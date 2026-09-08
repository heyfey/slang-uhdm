// r10uvm207 arm A — THE MEMBER GRID.  Every kind LAW S covers, as a MEMBER of a
// package STRUCT typedef, bound by a declaration inside a WILDCARD-IMPORT CLONE
// body.  Decides whether golden bares a clone-reached struct member's alias
// TARGET in general, and for which member kinds.  One real Surelog golden,
// both views.
package p207a_s;
  typedef bit   [63:0]    bt207;
  typedef logic [15:0]    lt207;
  typedef int             it207;
  typedef byte            yt207;
  typedef integer         gt207;
  typedef shortint        ht207;
  typedef longint         nt207;

  typedef struct {                       // the uvm_reg_bus_op / addr_range shape
    bt207 m_b207;
    lt207 m_l207;
    it207 m_i207;
    int   m_plain207;                    // NOT a typedef: the control member
  } su207;

  typedef struct packed {                // the PACKED shape
    bt207 p_b207;
    lt207 p_l207;
  } sp207;

  typedef struct {                       // every remaining LAW-S kind
    yt207 k_y207;
    gt207 k_g207;
    ht207 k_h207;
    nt207 k_n207;
  } sk207;

  function automatic int fa207();
    su207 la207;                         // the home body's own local
    sp207 lp207;
    sk207 lk207;
    return int'(la207.m_i207) + int'(lp207.p_l207) + int'(lk207.k_g207);
  endfunction
endpackage

package p207b_s;
  import p207a_s::*;                     // WILDCARD: the clone lives here
  function automatic int gb207();
    return fa207();
  endfunction
endpackage

module g207_a_struct;
  import p207b_s::*;
  int r207;
  initial r207 = gb207();
endmodule
