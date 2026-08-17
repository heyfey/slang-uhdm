// v87 arm a8 — exotic reaches: interface class defaults, wildcard-import
// clones, deep statement blocks (fork/for/foreach), local/protected typedefs,
// specialization overrides, and the vpiInstance hazard on a NAMED body local.
package p87e;
  class e87; int x; endclass
  interface class ic87;
    pure virtual function void g();
  endclass
  class impl87 implements ic87;
    virtual function void g(); endfunction
  endclass

  class w87 #(type REQ = e87, type RSP = REQ);
    typedef RSP rsp_t;
    REQ p;
    function void deep();
      REQ l0;
      for (int i = 0; i < 2; i++) begin
        REQ l1;
        fork
          begin
            REQ l2;
            l2 = l1;
          end
        join_none
      end
      l0 = p;
    endfunction
    function void arr();
      REQ la[$];
      foreach (la[i]) begin
        REQ lf;
        lf = la[i];
      end
    endfunction
  endclass

  class v87 #(type REQ = e87, type RSP = REQ);
    local typedef RSP rsp_t;
    REQ p;
  endclass

  class pv87 #(type REQ = e87, type RSP = REQ);
    protected typedef RSP rsp_t;
    REQ p;
  endclass

  class icp87 #(type T = ic87);
    typedef T t_t;
    T p;
  endclass
endpackage

package p87f;
  import p87e::*;
  class use87 #(type REQ = e87, type RSP = REQ);
    typedef RSP rsp_t;
    REQ p;
    function void f(); REQ l; l = p; endfunction
  endclass
  function automatic void topf();
    w87 #(e87) h;
    h = null;
  endfunction
endpackage

module m87a8;
  import p87e::*;
  import p87f::*;
  w87 #(e87)       s0;
  w87 #(e87, e87)  s1;
  use87 #(e87)     s2;
  initial begin end
endmodule
