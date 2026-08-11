// r10uvm51 arm a4 — HEAD 3, uncovered by laws 1+2.
// Corpus witness: uvm-1.2 base/uvm_pool.svh:87 `if (!pool.exists(key))` inside
// `virtual function T get (KEY key);`.  LHS golden / RHS ours at that point:
//   golden  ref_obj (uvm_pkg::uvm_pool::get::pool.exists::key)  NO vpiActual
//   ours    ref_obj (uvm_pkg::uvm_pool::get::key)               vpiActual -> io_decl
// so the question this arm answers is WHICH argument ref_objs golden leaves
// UNBOUND, because golden binds 6911 ref_objs to io_decls in the same database
// and a blanket "never bind an argument" would be catastrophically wide.
// Cells: built-in method on an assoc array / on a queue, a user method through
// an object handle, a plain (unqualified) function call, and a local variable
// rather than a formal as the argument.
package p51c;

  class d51;
    function int m51(int v);
      return v;
    endfunction
  endclass

  class c51;
    int pool[string];
    int q51[$];
    d51 h51;

    function int g51(int v);
      return v;
    endfunction

    function int f51(string key, int v);
      int loc;
      loc = v;
      if (!pool.exists(key))          // 1: BUILT-IN method on an assoc array
        pool[key] = v;
      q51.push_back(v);               // 2: BUILT-IN method on a queue
      loc = h51.m51(v);               // 3: USER method through an object handle
      loc = g51(v);                   // 4: PLAIN unqualified call
      loc = h51.m51(loc);             // 5: same as 3 but the arg is a LOCAL
      if (!pool.exists("lit"))        // 6: literal argument, no ref at all
        loc = 0;
      return loc;
    endfunction
  endclass

  // 7/8 — THE CLASS-vs-PACKAGE DISTINGUISHER, measured on ONE binary so the
  // two halves cannot be an artefact of two different runs.  SimpleUVM's golden
  // BINDS a package function's call arguments (uvm_hdl_force_time calling
  // uvm_hdl_deposit(path, value), g.dump:5288 — `vpiActual -> io_decl`), while
  // the same shape inside a CLASS METHOD is left UNBOUND.
  function automatic int pkgcallee51(int a, int b);
    return a + b;
  endfunction

  function automatic int pkgcaller51(int p, int v);
    int r;
    r = pkgcallee51(p, v);   // 7: PACKAGE function calling a PACKAGE function
    return r;
  endfunction

endpackage

module a4_top;
  import p51c::*;
  c51 c1;
endmodule
