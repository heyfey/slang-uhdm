// r10uvm177 grid arm D — THE GATE'S OWN BOUNDARY.
// Every shape adjacent to § ownNamedAliasRetIsRefVar177's four terms, so the
// cells that MUST NOT move are named and scored rather than assumed:
//   * an INHERITED class alias (owner is the BASE class, not the compiling one)
//   * a $unit alias named from a $unit function (the deliberate residue)
//   * an alias of a PARAMETER TYPE, and a `parameter type` return itself
//   * a class-scope alias named from a class in ANOTHER package
//   * a typedef whose base is a named type WITH dimensions (§22's arm)
//   * a typedef of a CLASS handle (§ aliasClassRefVar10 already answers)
//   * a forward-declared class typedef
typedef enum { D_ONE, D_TWO } dunit_e;
typedef dunit_e DUnitVia;
function DUnitVia unit_fn(); return D_ONE; endfunction   // $unit fn, $unit alias

package dbase177;
  typedef enum { B_L, B_M } bbase_e;
  typedef bbase_e BbaseVia;
  typedef struct packed { bit [1:0] w; } brec_t;
  typedef brec_t BrecVia;
endpackage

package dpk177;
  import dbase177::*;

  class Parent177;
    typedef enum { P_R, P_S } par_e;      // BASE class direct enum td
    typedef par_e ParVia;                 // BASE class ALIAS
    function ParVia pv_own(); return P_R; endfunction
  endclass

  class Child177 extends Parent177;
    typedef enum { C_T, C_U } chi_e;
    typedef chi_e ChiVia;                 // CHILD's OWN alias
    // an INHERITED alias, named from the child: owner is Parent177
    function ParVia cv_inherited(); return P_S; endfunction
    function ChiVia cv_own();       return C_T; endfunction
    function par_e  cv_inh_direct(); return P_R; endfunction
  endclass

  class Parm177 #(type T = int);
    typedef T TVia;                       // alias of a PARAMETER TYPE
    function TVia tv_param(); return 0; endfunction
    function T    t_param();  return 0; endfunction
  endclass

  typedef bbase_e ImpVia;                 // alias of an IMPORTED typedef
  typedef int dq_base [4];
  typedef dq_base DqVia;                  // named base WITH the array shape
  typedef int dq_dims [2];

  class Fwd177; int z; endclass
  typedef Fwd177 FwdVia;                  // alias of a class handle

  function ImpVia  d_impvia();   return B_L; endfunction
  function BbaseVia d_farvia();  return B_M; endfunction
  function DqVia   d_qvia();     return '{default:0}; endfunction
  function dq_base d_qdirect();  return '{default:0}; endfunction
  function FwdVia  d_clsvia();   return null; endfunction
  // (a $unit alias named from a package is slang-rejected; see arm C)
endpackage

module dtop177;
  import dpk177::*;
  initial begin
    Child177 c; Parm177#(int) p;
    c = new(); p = new();
    $display(unit_fn(), d_impvia(), d_farvia(), d_clsvia(),
             c.cv_own(), c.cv_inherited(), p.tv_param());
  end
endmodule
