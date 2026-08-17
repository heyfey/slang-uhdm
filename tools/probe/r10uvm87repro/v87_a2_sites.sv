// v87 arm a2 — DECLARATION SITES: properties, arrays, formals by direction,
// returns, body/nested locals, casts, virtual/pure, typedef-spelled uses.
package p87w;
  class b87; int x; endclass
  class s87 #(type REQ = b87, type RSP = REQ);
    typedef RSP rsp_t;
    REQ  p_scalar;
    RSP  p_scalar2;
    rand REQ p_rand;
    static REQ p_static;
    local REQ p_local;
    protected REQ p_prot;
    REQ q_queue[$];
    REQ d_dyn[];
    REQ f_fix[4];
    REQ a_assoc[string];
    REQ a_assoc2[int];
    rsp_t p_td;
    rsp_t q_td[$];

    function void f_val(REQ a); endfunction
    function void f_ref(ref REQ a); endfunction
    function void f_cref(const ref REQ a); endfunction
    function void f_out(output REQ a); endfunction
    function void f_inout(inout REQ a); endfunction
    function void f_td(rsp_t a); endfunction

    function REQ f_ret(); return null; endfunction
    function RSP f_ret2(); return null; endfunction
    function rsp_t f_ret3(); return null; endfunction

    function void f_loc();
      REQ l_v;
      rsp_t l_td;
      begin
        REQ l_nested;
        l_nested = l_v;
      end
    endfunction
    task t_loc();
      REQ l_t;
      l_t = p_scalar;
    endtask
    function void f_cast();
      REQ lv;
      b87 bb;
      void'($cast(lv, bb));
    endfunction
    virtual function void vf(REQ a); endfunction
  endclass

  virtual class sv87 #(type REQ = b87, type RSP = REQ);
    typedef RSP rsp_t;
    pure virtual function void pvf(REQ a);
    pure virtual function REQ pvr();
  endclass
endpackage

module m87a2;
  import p87w::*;
  s87 #(b87) i0;
  initial begin end
endmodule
