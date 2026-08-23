// r10buvm28 grid B — § enumNoBaseTypespecZeroBits28, the PROPAGATION half.
// Where does a base-less enum's ZERO travel?  Fixed / dynamic / queue /
// associative / 2-D unpacked arrays of one, packed and unpacked STRUCTS and a
// packed UNION containing one, the TYPE names of all of those, a member reached
// through `.`, an enum MEMBER, `$clog2($bits(...))`, and a declaration whose
// RANGE is written `[$bits(e)-1:0]`.  In a class body, a ported module `initial`
// and three module localparams.  Golden = Surelog; scored by spanval.py.
// r10buvm28 grid B — where does a BASE-LESS enum's zero width propagate?
package q28;
  typedef enum { N0, N1, N2 } e_bare;          // NO base type  -> Bits()==0
  typedef enum bit [3:0] { M0, M1 } e_b4;      // explicit base -> 4
  typedef struct packed { e_bare c; bit [7:0] d; } ps_t;    // packed struct
  typedef struct { e_bare c; bit [7:0] d; } us_t;           // unpacked struct
  typedef union packed { e_b4 a; bit [3:0] b; } pu_t;
  typedef e_bare arr_t [4];                    // fixed unpacked array of enums

  class D;
    e_bare      p_e;
    e_bare      p_ea [4];      // fixed unpacked array
    e_bare      p_ed [];       // dynamic
    e_bare      p_eq [$];      // queue
    e_bare      p_eaa [string];
    ps_t        p_ps;
    us_t        p_us;
    pu_t        p_pu;
    arr_t       p_arr;
    e_bare      p_e2d [2][3];
    logic [$bits(e_bare)-1:0] p_dep;   // a DECLARATION that uses it

    function void f();
      int r[40];
      r[0]  = $bits(p_ea);        // array of base-less enums
      r[1]  = $bits(p_ea[0]);     // select -> root rule
      r[2]  = $bits(p_ed);
      r[3]  = $bits(p_ed[0]);
      r[4]  = $bits(p_eq);
      r[5]  = $bits(p_eaa["k"]);
      r[6]  = $bits(p_ps);        // packed struct WITH a base-less enum member
      r[7]  = $bits(p_ps.c);
      r[8]  = $bits(p_ps.d);
      r[9]  = $bits(p_us);        // unpacked struct
      r[10] = $bits(p_us.c);
      r[11] = $bits(p_pu);
      r[12] = $bits(p_arr);
      r[13] = $bits(p_e2d);
      r[14] = $bits(ps_t);
      r[15] = $bits(us_t);
      r[16] = $bits(arr_t);
      r[17] = $bits(pu_t);
      r[18] = $bits(N1);          // an enum MEMBER
      r[19] = $bits(p_e);
      r[20] = $bits(e_b4);
      r[21] = $clog2($bits(e_bare));
      r[22] = $bits(p_dep);
    endfunction
  endclass
endpackage

module t28 (output int oo);
  import q28::*;
  q28::e_bare  mv;
  q28::ps_t    mps;
  q28::us_t    mus;
  q28::arr_t   marr;
  int z[12];
  initial begin
    z[0] = $bits(mv);
    z[1] = $bits(mps);
    z[2] = $bits(mps.c);
    z[3] = $bits(mus);
    z[4] = $bits(marr);
    z[5] = $bits(marr[1]);
    z[6] = $bits(q28::e_bare);
    z[7] = $bits(q28::ps_t);
  end
  localparam int LPA = $bits(q28::e_bare);
  localparam int LPB = $bits(q28::ps_t);
  localparam int LPC = $bits(q28::us_t);
  assign oo = $bits(mv) + $bits(mps);
endmodule
