// r10uvm40 arm t57a — the DECLARATION-EMISSION law for a subroutine BODY-LOCAL
// ASSOCIATIVE array.  91 BINDWRONG rows on all four UVM-4 tests are
// `array_var` (golden) vs `logic_var` (ours) on exactly this shape:
//   function void uvm_phase::sync(...);  int visited[uvm_phase];
// Every declaration form is present BOTH in an OUT-OF-BODY class method (the
// UVM spelling) and in an IN-BODY class method and a package FREE FUNCTION, so
// the law's reach across the three productions is measured, not assumed.
// NEGATIVES in the same golden: a plain scalar and a packed vector must stay
// logic_var/bit_var, and a paren-LESS function header must keep the TF-ITEM
// model (no array_var at all) — the § blockItems9 gate.
package pk57;

  class key57;
    int k;
  endclass

  // ---------------------------------------------------------------- out-of-body
  class oob57;
    extern function void mAssocCls57();
    extern function void mAssocStr57();
    extern function void mAssocInt57();
    extern function void mAssoc2d57();
    extern function void mQueue57();
    extern function void mDyn57();
    extern function void mFixed57();
    extern function void mNeg57();
    extern task tAssoc57();
  endclass

  function void oob57::mAssocCls57();
    bit acls[key57];
    acls[null] = 1;
  endfunction

  function void oob57::mAssocStr57();
    int astr[string];
    astr["a"] = 1;
  endfunction

  function void oob57::mAssocInt57();
    key57 aint[int];
    aint[3] = null;
  endfunction

  function void oob57::mAssoc2d57();
    int a2d[string][string];
    a2d["a"]["b"] = 1;
  endfunction

  function void oob57::mQueue57();
    int aq[$];
    aq.push_back(1);
  endfunction

  function void oob57::mDyn57();
    int ad[];
    ad = new [2];
  endfunction

  function void oob57::mFixed57();
    int af[4];
    af[0] = 1;
  endfunction

  function void oob57::mNeg57();
    bit nsc;
    bit [7:0] nvec;
    string nstr;
    nsc = 1;
    nvec = 8'h5;
    nstr = "x";
  endfunction

  task oob57::tAssoc57();
    int taq[key57];
    taq[null] = 1;
  endtask

  // ------------------------------------------------------------------ in-body
  class inb57;
    function void iAssocCls57();
      bit iacls[key57];
      iacls[null] = 1;
    endfunction
    function void iAssocStr57();
      int iastr[string];
      iastr["a"] = 1;
    endfunction
    function void iQueue57();
      int iaq[$];
      iaq.push_back(1);
    endfunction
    // the paren-LESS header: the TF-ITEM production, no array_var
    function void iNoParen57;
      int npa[key57];
      npa[null] = 1;
    endfunction
  endclass

  // -------------------------------------------------------- package function
  function void fAssocCls57();
    bit facls[key57];
    facls[null] = 1;
  endfunction

  function void fAssocStr57();
    int fastr[string];
    fastr["a"] = 1;
  endfunction

  // ------------------------------------------------------ a `begin` block local
  function void fBlkAssoc57();
    begin
      int bacls[key57];
      bacls[null] = 1;
    end
  endfunction

endpackage

module top57;
  import pk57::*;
  // a MODULE-scope subroutine with the same shape
  function void mmAssoc57();
    int mmacls[key57];
    mmacls[null] = 1;
  endfunction
  initial mmAssoc57();
endmodule
