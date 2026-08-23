// r10buvm28 grid A — § enumNoBaseTypespecZeroBits28.
// Every enum BASE spelling (none / int / integer / shortint / byte / bit[3:0] /
// logic[7:0] / typedef alias / inline anonymous) x every home (class property,
// function local, function formal, package variable, TYPE name, scoped TYPE
// name, package function, module variable, module localparam), plus the shapes
// that must NOT move ($size, an enum MEMBER, an explicit-base enum).
// Golden = Surelog; scored by spanval.py on the two uhdm-dumps.
package p2;
  typedef enum { A0, A1, A2 } e_bare;                  // no base
  typedef enum int { B0, B1 } e_int;                   // explicit int
  typedef enum bit [3:0] { C0, C1 } e_bit4;            // explicit bit[3:0]
  typedef enum logic [7:0] { D0, D1 } e_log8;          // explicit logic[7:0]
  typedef enum byte { G0, G1 } e_byte;                 // explicit byte
  typedef enum { H0 = 1, H1 = 0, H2 = -1 } e_neg;      // no base, negative
  typedef enum integer { I0, I1 } e_integer;
  typedef e_bare e_alias;
  typedef enum shortint { J0 } e_shortint;

  e_bare  pv_bare;                                     // package variable

  class C;
    e_bare    p_bare;
    e_int     p_int;
    e_bit4    p_bit4;
    e_log8    p_log8;
    e_byte    p_byte;
    e_neg     p_neg;
    e_integer p_integer;
    e_alias   p_alias;
    e_shortint p_short;
    enum { K0, K1 } p_anon;                            // inline anonymous enum
    function void f(e_bare fa);
      e_bare lv;
      int r[32];
      r[0]  = $bits(p_bare);
      r[1]  = $bits(p_int);
      r[2]  = $bits(p_bit4);
      r[3]  = $bits(p_log8);
      r[4]  = $bits(p_byte);
      r[5]  = $bits(p_neg);
      r[6]  = $bits(p_integer);
      r[7]  = $bits(p_alias);
      r[8]  = $bits(p_short);
      r[9]  = $bits(p_anon);
      r[10] = $bits(lv);
      r[11] = $bits(fa);
      r[12] = $bits(pv_bare);
      r[13] = $bits(e_bare);
      r[14] = $bits(e_int);
      r[15] = $bits(e_bit4);
      r[16] = $bits(e_neg);
      r[17] = $bits(p2::e_bare);
      r[18] = $bits(A0);
      r[19] = $size(p_bare);
      r[20] = $bits(p_bare) + 1;
    endfunction
  endclass

  function automatic int pf();
    e_bare lf;
    return $bits(lf) + $bits(e_bare) + $bits(e_bit4);
  endfunction
endpackage

module m2;
  import p2::*;
  e_bare mv;
  p2::e_bit4 mv4;
  int q0, q1, q2, q3;
  initial begin
    q0 = $bits(mv);
    q1 = $bits(mv4);
    q2 = $bits(p2::e_bare);
    q3 = $bits(e_bare);
  end
  localparam int LP0 = $bits(p2::e_bare);
  localparam int LP1 = $bits(p2::e_bit4);
endmodule
