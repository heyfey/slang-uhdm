// r10uvm11 t1 — for-loop header with a CLASS-TYPED loop variable declared
// inline and initialised from a method call on a class handle:
//     for (Inner it = h.first(); it != null; it = h.next())
// This is the UVM `for (uvm_reg_cbs cb = cbs.first(); cb != null;
// cb = cbs.next())` shape (uvm_reg_field.svh:1135 and ~60 more sites).
// Controls: an int-typed loop var in the same method, a statement call, an
// expression call, and an externally-declared class loop var.
package p1;

  class Inner;
    int v;
    function int val(); return v; endfunction
    function void doit(); v = 1; endfunction
  endclass

  class Iter;
    Inner q[$];
    int idx;
    function Inner first(); idx = 0; return q.size() ? q[0] : null; endfunction
    function Inner next(); idx++; return idx < q.size() ? q[idx] : null; endfunction
    function int size(); return q.size(); endfunction
  endclass

  class Caller;
    Iter h;

    // A. class-typed loop var declared IN the for header, initialised by a
    //    method call on a class handle.
    function void a_classvar_header();
      for (Inner it = h.first(); it != null; it = h.next())
        it.doit();
    endfunction

    // B. control: int loop var, method call only in the CONDITION.
    function void b_intvar_header();
      for (int i = 0; i < h.size(); i++)
        h.q[i].doit();
    endfunction

    // C. control: class loop var declared OUTSIDE, assigned in the header.
    function void c_classvar_external();
      Inner it2;
      for (it2 = h.first(); it2 != null; it2 = h.next())
        it2.doit();
    endfunction

    // D. control: statement position and expression position, no loop.
    function void d_plain();
      Inner x;
      h.q[0].doit();
      x = h.first();
      $display("%0d", h.size());
    endfunction

    // E. class loop var, non-call initialiser (null) — is the TYPE alone
    //    enough to drop the loop, or does the call matter?
    function void e_classvar_null_init();
      for (Inner it3 = null; it3 != null; it3 = h.next())
        it3.doit();
    endfunction

    // F. string-typed loop var (another non-integral type).
    function void f_stringvar();
      for (string sv = "a"; sv != "z"; sv = "z")
        $display(sv);
    endfunction
  endclass

endpackage

module top;
  p1::Caller c;
  initial begin
    c = new();
    c.a_classvar_header();
  end
endmodule
