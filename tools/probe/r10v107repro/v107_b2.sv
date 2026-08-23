// r10v107 arm b2 — THE `= new` FENCE's CORNERS.  MEASUREMENT ONLY.
// lhsOfWrittenNewAsg107 walks up the syntax parents and returns TRUE for
// ANYTHING reached from the LEFT of an assignment whose right side is a `new`,
// including an INDEX on that left side; and FALSE for anything on the RIGHT,
// including the constructor ARGUMENTS of that same `new`.  Golden decides.
package pb2;

  class d2;
    int fld;
    function new(d2 a = null); endfunction
  endclass

  class hold2;
    d2 f;
    d2 arr[4];
  endclass

  class c2 #(type T = d2);
    hold2 h;
    d2    plain;
    extern function void newlhs_plain();     // the CONTROL a1 measured: `v = new()`
    extern function void newlhs_index();     // index on the LHS of `= new`
    extern function void newrhs_ctorarg();   // ref_var local as a CONSTRUCTOR ARG
    extern function void newarr_size();      // ref_var local as `new[n]` size
    extern function void newlhs_field();     // `h.f = new()` with a ref_var elsewhere
    extern function void ordinary_asg();     // the ordinary-RHS control
  endclass

  function void c2::newlhs_plain();
    T v;
    v = new();
    plain = v;
  endfunction

  function void c2::newlhs_index();
    int ix;
    h.arr[ix] = new();
  endfunction

  function void c2::newrhs_ctorarg();
    T v;
    plain = new(v);
  endfunction

  function void c2::newarr_size();
    int n;
    d2 dyn[];
    dyn = new[n];
  endfunction

  function void c2::newlhs_field();
    T v;
    h.f = new();
    plain = v;
  endfunction

  function void c2::ordinary_asg();
    T v;
    v = plain;
    plain = v;
  endfunction

endpackage

module topb2;
  import pb2::*;
  c2 #(d2) inst;
  initial begin
    inst = new();
  end
endmodule
