// v87 arm a5 — OVER-FIRE probes: an unrelated class typedef whose canonical
// type coincides with a type parameter's resolved class, qualified spellings,
// `#(...)`-and-`::` spellings, forward typedefs, nested classes.
package p87y;
  class b87; int x; endclass
  class q87 #(type T = b87);
    T h;
    class innerq87; int z; endclass
  endclass

  class of87 #(type REQ = b87, type RSP = REQ);
    typedef RSP rsp_t;
    typedef b87 alias_t;
    alias_t p_alias;
    b87     p_direct;
    REQ     p_req;
    function void f();
      alias_t l_alias;
      b87     l_direct;
      l_direct = l_alias;
    endfunction
  endclass

  class nest87 #(type REQ = b87, type RSP = REQ);
    typedef RSP rsp_t;
    class inner87; int z; endclass
    inner87 pi;
    REQ pr;
  endclass

  class sp87 #(type T = p87y::b87);
    typedef T t_t;
    T p;
  endclass
  class sp2_87 #(type T = q87#(b87));
    typedef T t_t;
    T p;
  endclass
  class sp3_87 #(type T = q87#(b87)::innerq87);
    typedef T t_t;
    T p;
  endclass

  typedef class fwd87;
  class fwdholder87 #(type REQ = b87, type RSP = REQ);
    typedef RSP rsp_t;
    fwd87 pf;
    REQ   pr;
  endclass
  class fwd87; int w; endclass
endpackage

module m87a5;
  import p87y::*;
  of87 #(b87) i0;
  initial begin end
endmodule
