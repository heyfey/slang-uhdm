// r10vbuvm28 arm B — HOMES + new[] SHAPES.  Same base-less enum, every place
// a $bits can live and every dynamic-array new[] spelling the brief names.
package phomes;
  typedef enum { P0, P1 } pe_t;
  typedef enum byte { Q0, Q1 } qe_t;
  parameter int PW = 7;
  pe_t pkg_var;
  function automatic int pkgf(pe_t f);
    bit d [];
    d = new [$bits(f)];
    d = new [$bits(pe_t)];
    d = new [$bits(pkg_var)];
    return $bits(f) + $bits(pe_t) + $bits(pkg_var);
  endfunction
endpackage

class cbody;
  typedef enum { C0, C1 } ce_t;
  rand ce_t m_c;
  ce_t      m_arr [];
  ce_t      m_q [$];
  ce_t      m_aa [string];
  bit       __array [];
  static ce_t s_c;
  int        w;
  function new();
    __array = new [$bits(m_c)];                 // ctor
    w = $bits(m_c);
  endfunction
  function void inbody();
    __array = new [$bits(m_c)] (__array);       // WITH the source-array arg
    __array = new [$bits(m_c)];                 // without
    __array = new [$bits(ce_t)];                // TYPE argument
    __array = new [$bits(s_c)];                 // static property
    __array = new [$bits(m_arr[0])];            // element select
    __array = new [$bits(m_q[0])];
    __array = new [$bits(m_aa["k"])];
    __array = new [$bits(m_c) + 1];             // arithmetic AROUND $bits
    __array = new [$clog2($bits(m_c) + 2)];     // nested sys call
    __array = new [phomes::pkgf(phomes::P0)];           // a call
    __array = new [8];                          // a literal
    __array = new [$size(m_arr)];               // $size
    __array = new [$high(m_arr, 1)];
  endfunction
  extern function void oob();
  static function void sfun();
    bit z [];
    z = new [$bits(s_c)];
  endfunction
endclass

function void cbody::oob();
  bit y [];
  y = new [$bits(m_c)];                          // OUT OF BLOCK
  y = new [$bits(ce_t)];
endfunction

interface ifb;
  typedef enum { I0, I1 } ie_t;
  ie_t iv;
  bit ia [];
  initial ia = new [$bits(iv)];
endinterface

program prg;
  typedef enum { R0v, R1v } re_t;
  re_t rv;
  bit ra [];
  initial ra = new [$bits(rv)];
endprogram

module gv28_b_homes;
  typedef enum { M0, M1 } me_t;
  me_t mv;
  me_t marr [3];
  bit  ma [];
  int  acc;
  localparam int LP = $bits(me_t);
  parameter  int PP = 4;
  ifb u_if();
  initial begin
    ma = new [$bits(mv)];
    ma = new [$bits(me_t)];
    ma = new [$bits(marr[1])];
    ma = new [$bits(phomes::pe_t)];
    ma = new [$bits(phomes::pkg_var)];
    ma = new [$bits(mv) * 2];
    acc = $bits(mv);
  end
  always @* acc = $bits(mv) + $bits(marr[0]);
  task automatic tk(me_t tf);
    bit tb [];
    tb = new [$bits(tf)];
  endtask
  function automatic int fn(input me_t ff, output int oo);
    bit fb [];
    fb = new [$bits(ff)];
    oo = $bits(ff);
    return $bits(ff);
  endfunction
endmodule
