package p;
  class Inner;
    int x;
  endclass
  typedef Inner pkg_inner_t;

  class C;
    typedef Inner cls_inner_t;
    cls_inner_t prop_c;     // class property, class-scope alias
    pkg_inner_t prop_p;     // class property, pkg-scope alias
    Inner       prop_d;     // class property, direct

    function cls_inner_t f_c();
      cls_inner_t lc;
      return lc;
    endfunction
    function pkg_inner_t f_p();
      pkg_inner_t lp;
      return lp;
    endfunction
    task t_a(cls_inner_t a, pkg_inner_t b, Inner c);
    endtask
  endclass

  pkg_inner_t pkg_var;
endpackage

module top;
  import p::*;
  pkg_inner_t mod_var;
  Inner mod_direct;
  initial begin
  end
endmodule
