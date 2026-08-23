// r10v107 arm b1 — NESTED CONTEXTS INSIDE an expression-position receiver call's
// argument list.  MEASUREMENT ONLY.  The patch raises recvUserMethodArgDepth107
// around the WHOLE argument list of `if (s.ask(...))` and never lowers it, so
// every shape nested inside that list inherits the window.  Golden decides.
package pb1;

  class d1;
    int fld;
    function int m(int a); return a; endfunction
  endclass

  class snk1;
    function int  ask(d1 v);              return 0; endfunction
    function int  ask2(int a);            return 0; endfunction
    function int  askq(d1 a, d1 b);       return 0; endfunction
    function void take(d1 v); endfunction
  endclass

  class c1 #(type T = d1);
    snk1 s;
    snk1 s2;
    d1   plain;
    d1   qv[$];
    int  iq[$];
    extern function void nest_usercall();     // receiver-LESS call nested in the arg list
    extern function void nest_recvcall();     // a SECOND receiver call nested in the arg list
    extern function void nest_concat();       // concat member inside the arg list
    extern function void nest_index();        // index expression inside the arg list
    extern function void nest_builtin();      // built-in method call inside the arg list
    extern function void nest_ternary();      // ternary arms inside the arg list
    extern function void ctrl_direct();       // the CONTROL: the plain shape a1 measured
  endclass

  function void c1::nest_usercall();
    T v;
    if (s.ask(pass1(v)) == 0) begin
    end
  endfunction

  function void c1::nest_recvcall();
    T v;
    if (s.ask2(s2.ask(v)) == 0) begin
    end
  endfunction

  function void c1::nest_concat();
    int w;
    int z;
    if (s.ask2({w, z}) == 0) begin
    end
  endfunction

  function void c1::nest_index();
    int ix;
    if (s.ask2(iq[ix]) == 0) begin
    end
  endfunction

  function void c1::nest_builtin();
    T v;
    if (s.ask2(qv.sum with (int'(item == v))) == 0) begin
    end
  endfunction

  function void c1::nest_ternary();
    T v;
    T w;
    if (s.ask(plain == null ? v : w) == 0) begin
    end
  endfunction

  function void c1::ctrl_direct();
    T v;
    if (s.ask(v) == 0) begin
    end
  endfunction

  function d1 pass1(d1 a); return a; endfunction

endpackage

module topb1;
  import pb1::*;
  c1 #(d1) inst;
  initial begin
    inst = new();
  end
endmodule
