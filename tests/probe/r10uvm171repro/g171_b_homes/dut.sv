// r10uvm171 arm a2 — THE HOME GRID.  The same return-name select written in
// every HOME the corpus has, each one reachable from a wildcard-import clone,
// so the law's "package free subroutine only" half is scored rather than
// assumed.  A CLASS method (in-body and out-of-body) and a MODULE function are
// the negative controls: golden leaves their return-name selects bare in every
// view, including inside the importing package.
package home_src_171;
  // (1) the package's OWN free function — the law's subject.
  function string free_fn();
    int nq;
    free_fn = "vellum";
    nq = free_fn.len();
    free_fn[0] = free_fn[nq-1];
  endfunction

  // (2) a class method written INSIDE the class body.
  class InBody171;
    function string mth_in();
      int nq;
      mth_in = "cinnabar";
      nq = mth_in.len();
      mth_in[0] = mth_in[nq-1];
    endfunction
  endclass

  // (3) a class method DEFINED OUT OF BODY at package scope.
  class OutBody171;
    extern function string mth_out();
  endclass
  function string OutBody171::mth_out();
    int nq;
    mth_out = "sable";
    nq = mth_out.len();
    mth_out[0] = mth_out[nq-1];
  endfunction

  // (4) a VOID function and a TASK: neither has a return value, so neither can
  // produce a return-name reference at all.  Present so the grid records that
  // the law's population is empty here rather than leaving it unmeasured.
  function void void_fn(inout string sv);
    sv[0] = sv[sv.len()-1];
  endfunction
  task tsk_171(inout string sv);
    sv[0] = sv[sv.len()-1];
  endtask
  // The task is exercised from a MODULE initial block below: a function may
  // not call it, and an arm that never compiles the task tests nothing.
endpackage

package home_clone_171;
  import home_src_171::*;
  function int drive();
    string a1 = free_fn();
    InBody171 h1 = new();
    OutBody171 h2 = new();
    string a2 = h1.mth_in();
    string a3 = h2.mth_out();
    string a4;
    a4 = "topaz";
    void_fn(a4);
    return a1.len() + a2.len() + a3.len() + a4.len();
  endfunction
endpackage

// (5) a MODULE-scope function: no package home at all.
module home_top_171;
  import home_clone_171::*;
  function string mod_fn();
    int nq;
    mod_fn = "porphyry";
    nq = mod_fn.len();
    mod_fn[0] = mod_fn[nq-1];
  endfunction
  int rr;
  string ms;
  string ts;
  initial begin
    rr = drive();
    ms = mod_fn();
    ts = "girder";
    home_src_171::tsk_171(ts);
  end
endmodule
