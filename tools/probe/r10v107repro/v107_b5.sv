// r10v107 arm b5 — RECEIVER SPELLINGS and NAME-RESOLUTION corners in an
// out-of-body body: `this.m(v)`, `super.m(v)`, a chained receiver, a name
// SHADOWED BY A TYPEDEF, and a local whose type IS resolvable (the control).
// MEASUREMENT ONLY.
package pb5;

  typedef int shadow5;                 // a typedef whose name a local reuses

  class d5;
    int fld;
    function int m(int a); return a; endfunction
  endclass

  class snk5;
    function int ask(d5 v); return 0; endfunction
    function int askb(int a); return 0; endfunction
  endclass

  class hold5;
    snk5 s;
  endclass

  class base5;
    function int bask(d5 v); return 0; endfunction
    function int self(d5 v); return 0; endfunction
  endclass

  class c5 #(type T = d5) extends base5;
    snk5  s;
    hold5 h;
    d5    plain;
    extern function void recv_this();
    extern function void recv_super();
    extern function void recv_chain();
    extern function void nm_shadow();
    extern function int  self_ask(d5 v);
    extern function void ctrl_resolvable();
  endclass

  function void c5::recv_this();
    T v;
    if (this.self_ask(v) == 0) begin
    end
  endfunction

  function void c5::recv_super();
    T v;
    if (super.bask(v) == 0) begin
    end
  endfunction

  function void c5::recv_chain();
    T v;
    if (h.s.ask(v) == 0) begin
    end
  endfunction

  function void c5::nm_shadow();
    T shadow5;                        // a LOCAL that shadows the typedef name
    if (s.ask(shadow5) == 0) begin
    end
  endfunction

  function int c5::self_ask(d5 v);
    return 0;
  endfunction

  function void c5::ctrl_resolvable();
    d5 v;
    if (s.ask(v) == 0) begin
    end
  endfunction

endpackage

module topb5;
  import pb5::*;
  c5 #(d5) inst;
  initial inst = new();
endmodule
