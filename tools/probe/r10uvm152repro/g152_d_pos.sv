// r10uvm152 arm D — THE POSITIONS.  One out-of-body EMPTY-PAREN constructor
// whose FIRST body element is eaten; every name declared there is read from a
// different syntactic position, including the two § pkgSubRefBindsPkgVarOver
// Formal81 calls EARLY-BOUND (an if predicate and a case condition/item).
package pd152;

  class Kd152;
    int qd;
    function int val(); return qd; endfunction
  endclass

  function void sink152(Kd152 x); endfunction

  class Ad152;
    int zd;
    extern function new();
  endclass

  function Ad152::new();
    Kd152 d_asg, d_rhs, d_arg, d_ifc, d_casec, d_casei, d_whi, d_for,
          d_ret, d_assert, d_nest, d_fork, d_fore, d_idx;
    int    k;
    d_asg = null;                                   // lvalue
    k = (d_rhs == null) ? 1 : 2;                    // rhs operand
    sink152(d_arg);                                 // call argument
    if (d_ifc != null) k = 3;                       // IF PREDICATE  (early-bound half of § 81)
    case (d_casec)                                  // CASE CONDITION
      null: k = 4;
      default: k = 5;
    endcase
    case (k)
      d_casei.val(): k = 6;                         // CASE ITEM EXPRESSION
      default: k = 7;
    endcase
    while (d_whi != null) k = 8;
    for (int i = 0; i < 2; i++) if (d_for != null) k = 9;
    begin
      Kd152 inner_d;
      inner_d = d_nest;
    end
    begin : nb_d
      if (d_fork != null) k = 10;
    end
    assert (d_assert != null) k = 11;
    zd = k;
  endfunction

  function int fetch152();
    Ad152 a;
    a = new();
    return a.zd;
  endfunction

endpackage

module md152;
  import pd152::*;
  int r;
  initial r = fetch152();
endmodule
