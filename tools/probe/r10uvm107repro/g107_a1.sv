// r10uvm107 arm a1 — THE REFERENCE-POSITION GRID for § oobRefVarLocalHoistNet107.
// MEASUREMENT ONLY.  One package class with a TYPE PARAMETER, one OUT-OF-BODY
// method per reference position, and a module that wildcard-imports the package
// so Surelog's UhdmWriter::lateBinding has a module to mint into.
// Controls (`ct_*`) use a RESOLVABLE local type in the identical positions.
package p107;

  class d107;
    int fld;
    function int m(int a); return a; endfunction
  endclass

  class sink107;
    function void take(d107 v); endfunction
    function int  ask(d107 v); return 0; endfunction
    task tk(d107 v); endtask
  endclass

  class q107;
    d107 q[$];
  endclass

  class c107 #(type T = d107);
    sink107 s;
    q107    qq;
    d107    qv[$];
    d107    plain;
    extern function void oob_userarg();       // user call, RECEIVER-LESS
    extern function void oob_recvarg();       // user call, CLASS RECEIVER
    extern function void oob_recvexpr();      // user call, CLASS RECEIVER, EXPRESSION position
    extern function void oob_builtinarg();    // BUILT-IN method argument
    extern function void oob_sysarg();        // system call argument ($cast)
    extern function void oob_deep();          // user call one control body deeper
    extern function void oob_asg();           // assignment LHS and RHS
    extern function int  oob_cond();          // if condition
    extern function void oob_recvcall();      // the local AS THE RECEIVER
    extern function int  oob_ret();           // returned value
    extern function void ct_userarg();        // the control: resolvable type
    function void ib_userarg();               // the IN-BODY twin
      T ib;
      s.take(ib);
    endfunction
  endclass

  function void c107::oob_userarg();
    T v;
    plain_take(v);
  endfunction

  function void c107::oob_recvarg();
    T v;
    s.take(v);
  endfunction

  function void c107::oob_recvexpr();
    T v;
    if (s.ask(v) == 0) begin
    end
    if (s.ask(v) != 1) begin
      s.take(v);
    end
  endfunction

  function void c107::oob_builtinarg();
    T v;
    qv.push_back(v);
  endfunction

  function void c107::oob_sysarg();
    T v;
    if ($cast(v, plain)) begin
    end
    if (!$cast(v, plain)) begin
    end
  endfunction

  function void c107::oob_deep();
    T v;
    if (plain != null) begin
      plain_take(v);
      s.take(v);
    end
  endfunction

  function void c107::oob_asg();
    T v;
    v = plain;
    plain = v;
  endfunction

  function int c107::oob_cond();
    T v;
    if (v == null) return 1;
    return 0;
  endfunction

  function void c107::oob_recvcall();
    T v;
    void'(v.m(1));
  endfunction

  function int c107::oob_ret();
    T v;
    return v.fld;
  endfunction

  function void c107::ct_userarg();
    d107 v;
    plain_take(v);
    s.take(v);
  endfunction

  function void plain_take(d107 v); endfunction

endpackage

module top107;
  import p107::*;
  c107 #(d107) inst;
  initial begin
    inst = new();
  end
endmodule
