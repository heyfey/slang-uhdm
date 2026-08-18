// v2: SITE axis inside a package class -- OOB vs in-body, static/virtual/extern,
// task vs function, formals in/out/inout/ref/default, locals, static locals, properties.
package vp2;
  parameter int PW = 4096;
  typedef logic signed [PW-1:0] bs_t;

  class C2;
    bs_t              prop_bare;
    vp2::bs_t         prop_qual;
    static bs_t       prop_static;
    rand bit [3:0]    r;

    // in-body function, bare return
    function bs_t inb();      inb = 'b0; endfunction
    // in-body virtual
    virtual function bs_t inb_v(); inb_v = 'b0; endfunction
    // in-body static
    static function bs_t inb_s(); inb_s = 'b0; endfunction
    // in-body task with all formal directions + a default-valued formal
    task inb_tk(input bs_t a, output bs_t b, inout bs_t c, ref bs_t d, input bs_t e = 'b0);
      bs_t lv; static bs_t slv;
      lv = a; slv = lv; b = lv; c = lv; d = lv;
    endtask
    // in-body function with locals
    function bs_t inb_loc();
      bs_t l1; static bs_t l2; vp2::bs_t l3;
      l1 = 'b0; l2 = l1; l3 = l1; inb_loc = l3;
    endfunction

    extern function bs_t oob();
    extern virtual function bs_t oob_v();
    extern static function bs_t oob_s();
    extern task oob_tk(input bs_t a, output bs_t b, inout bs_t c, ref bs_t d, input bs_t e = 'b0);
    extern function bs_t oob_loc();
    extern function vp2::bs_t oob_q();
    extern function void oob_void(bs_t a);
  endclass

  function bs_t C2::oob();   oob   = 'b0; endfunction
  function bs_t C2::oob_v(); oob_v = 'b0; endfunction
  function bs_t C2::oob_s(); oob_s = 'b0; endfunction
  task C2::oob_tk(input bs_t a, output bs_t b, inout bs_t c, ref bs_t d, input bs_t e);
    bs_t lv; static bs_t slv;
    lv = a; slv = lv; b = lv; c = lv; d = lv;
  endtask
  function bs_t C2::oob_loc();
    bs_t l1; static bs_t l2; vp2::bs_t l3;
    l1 = 'b0; l2 = l1; l3 = l1; oob_loc = l3;
  endfunction
  function vp2::bs_t C2::oob_q(); oob_q = 'b0; endfunction
  function void C2::oob_void(bs_t a); bs_t l; l = a; endfunction

  // free package function baselines
  function bs_t free_ret(); free_ret = 'b0; endfunction
  function vp2::bs_t free_ret_q(); free_ret_q = 'b0; endfunction
endpackage

module vt2;
  import vp2::*;
  vp2::bs_t w;
  vp2::C2 c;
  initial begin c = new(); w = c.oob(); end
endmodule
