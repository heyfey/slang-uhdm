// v87 arm a9 — no-default parameters, nested-class defaults, constraints and
// covergroups, typedef declared after use, re-declared typedef in a derived
// class, and a qualified typedef target.
package p87g;
  class g87; int x; endclass
  class outer87;
    class inner87; int z; endclass
  endclass

  // no default, overridden at every use
  class n87 #(type REQ = g87, type RSP = REQ);
    typedef RSP rsp_t;
    REQ p;
  endclass

  // nested-class default
  class d87 #(type T = outer87::inner87);
    typedef T t_t;
    T p;
  endclass

  // typedef written AFTER the declarations that use the parameter
  class l87 #(type REQ = g87, type RSP = REQ);
    REQ p_first;
    function void f(); REQ l; l = p_first; endfunction
    typedef RSP rsp_t;
    REQ p_last;
  endclass

  // constraints + covergroup over a type-parameter handle
  class r87 #(type REQ = g87, type RSP = REQ);
    typedef RSP rsp_t;
    rand int a;
    REQ h;
    constraint c_a { a inside {[0:3]}; }
    covergroup cg;
      coverpoint a;
    endgroup
    function new(); cg = new(); endfunction
  endclass

  // derived class re-declaring the SAME typedef name
  class base87 #(type REQ = g87, type RSP = REQ);
    typedef RSP rsp_t;
    REQ p_base;
  endclass
  class der87 #(type REQ = g87, type RSP = REQ) extends base87 #(REQ, RSP);
    typedef REQ rsp_t;
    REQ p_der;
  endclass

  // qualified typedef target
  class q87 #(type REQ = g87, type RSP = REQ);
    typedef RSP rsp_t;
    typedef p87g::g87 qual_t;
    REQ p;
    qual_t pq;
  endclass
endpackage

module m87a9;
  import p87g::*;
  n87 #(g87)      s0;
  n87 #(g87, g87) s1;
  d87             s2;
  l87 #(g87)      s3;
  initial begin end
endmodule
