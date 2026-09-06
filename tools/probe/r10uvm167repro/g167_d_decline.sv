// r10uvm167 grid, arm D — THE NEGATIVE CONTROL.  Every shape the law must NOT
// move.  Its two databases must be BYTE-IDENTICAL on the two binaries in both
// views; anything else is a regression this arm exists to catch.
//
// (r10uvm166 §4.4's trap: a first cut of that pass's decline arm compiled to
// NOTHING in Surelog and would have read green while testing nothing.  This one
// is checked by grid167.sh, which prints the units Surelog actually compiled.)
package dp167;

  class Rcv167;
    function int mf167(int a, int b = 3, int c = 5);
      return a + b + c;
    endfunction
    task mt167(int a, int b = 3);
    endtask
    function int nod167(int a, int b);       // NO defaults at all
      return a + b;
    endfunction
    function int zero167();                  // NO formals at all
      return 1;
    endfunction
  endclass

  function automatic int df167(int a, int b = 3);
    return a + b;
  endfunction

  class Plain167;                            // NOT generic: no shell possible
    int q[$];
    string s167;
    Rcv167 r167;

    function int d_positional();
      // ordinary POSITIONAL calls with trailing defaults — already correct
      return r167.mf167(1) + r167.mf167(1, 2) + r167.mf167(1, 2, 3);
    endfunction

    function int d_eqdefault();
      // WRITTEN arguments TEXTUALLY EQUAL to their defaults: they are WRITTEN
      // and must STAY.  A value/span test would eat these.
      return r167.mf167(1, 3, 5) + df167(1, 3);
    endfunction

    function int d_nodefault();
      return r167.nod167(1, 2) + r167.zero167();
    endfunction

    function int d_named();
      // a NAMED receiver-less call: golden lists ONE SLOT PER FORMAL and this
      // law must not shorten it (§ namedTfArgsFormalSlots4)
      return df167(.a(1)) + df167(.b(2), .a(1));
    endfunction

    function int d_builtin();
      // BUILT-IN methods: the receiver is `arguments()[0]`, so a written-count
      // trim would eat the receiver itself
      q.push_back(3);
      return q.size() + q.sum();
    endfunction

    function int d_system();
      // SYSTEM calls: no formals, no defaults
      $display("x %0d", 1);
      return $bits(s167) + $clog2(8);
    endfunction

    task d_task();
      r167.mt167(1);
      r167.mt167(1, 2);
    endtask

    function int d_empty();
      // WRITTEN-BUT-EMPTY slots: Surelog's own INT:0, not the formal default
      return r167.mf167(1, , 4) + df167(1, );
    endfunction
  endclass

endpackage

module dm167;
  import dp167::*;
  dp167::Plain167 p167;
  int z167;
  initial begin
    z167 = p167.d_positional() + p167.d_eqdefault() + p167.d_nodefault();
    z167 = z167 + p167.d_named() + p167.d_builtin() + p167.d_system();
    p167.d_task();
    z167 = z167 + p167.d_empty();
  end
endmodule
