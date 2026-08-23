// r10vbuvm28 arm A — COMPOSITION: does the zero propagate the way the law says?
// Every $bits here folds today (a bare name / type name / member access), so
// the patch's value substitution is the ONLY thing under test.
package pcompose;
  typedef enum { E0, E1, E2 } ebare_t;          // NO base type -> golden 0
  typedef enum int { F0, F1 } ebased_t;          // base int     -> golden 32
  typedef ebare_t ealias_t;                      // alias of a base-less enum

  typedef struct packed { ebare_t c; bit [7:0] d; }  ps_t;       // 0 + 8
  typedef struct packed { ebare_t c; ebare_t e; }    ps2_t;      // 0 + 0
  typedef struct         { ebare_t c; real     r; }  us_real_t;  // 0 + real
  typedef struct         { ebare_t c; shortreal sr; } us_sreal_t;// 0 + shortreal
  typedef struct         { ebare_t c; string   s; }  us_str_t;   // 0 + string
  typedef struct         { ebare_t c; time     t; }  us_time_t;  // 0 + time
  typedef struct         { ebare_t c; chandle  h; }  us_ch_t;    // 0 + chandle
  typedef struct         { ebare_t c; realtime rt; } us_rt_t;    // 0 + realtime
  typedef union  packed  { ebare_t c; int d; } pu_t;             // max(0,32)
  typedef union          { ebare_t c; bit [7:0] d; } uu_t;
  typedef struct         { ps_t inner; bit [3:0] q; } nest_t;    // (0+8) + 4
  typedef struct         { ebare_t a4 [4]; byte b; }  arrmem_t;  // 0*4 + 8
  typedef struct packed  { ebare_t [3:0] pk; bit b; } pkenum_t;  // 4*0 + 1
  typedef ebare_t   ea_fixed_t [4];
  typedef ebare_t   ea_dyn_t   [];
  typedef ebare_t   ea_q_t     [$];
  typedef ebare_t   ea_aa_t    [string];
  typedef ebare_t   ea_2d_t    [2][3];
  typedef ebare_t   ea_pk_t;                     // scalar alias
endpackage

module gv28_a_compose;
  import pcompose::*;
  ebare_t      v_bare;
  ebased_t     v_based;
  ealias_t     v_alias;
  ps_t         v_ps;
  ps2_t        v_ps2;
  us_real_t    v_usreal;
  us_sreal_t   v_ussreal;
  us_str_t     v_usstr;
  us_time_t    v_ustime;
  us_ch_t      v_usch;
  us_rt_t      v_usrt;
  pu_t         v_pu;
  uu_t         v_uu;
  nest_t       v_nest;
  arrmem_t     v_arrmem;
  pkenum_t     v_pkenum;
  ea_fixed_t   v_afix;
  ea_dyn_t     v_adyn;
  ea_q_t       v_aq;
  ea_aa_t      v_aaa;
  ea_2d_t      v_a2d;
  ebare_t [3:0] v_pkarr;
  int r [30];
  initial begin
    r[0]  = $bits(v_bare);
    r[1]  = $bits(v_based);
    r[2]  = $bits(v_alias);
    r[3]  = $bits(v_ps);
    r[4]  = $bits(v_ps2);
    r[5]  = 0; // $bits(real member) rejected by slang
    r[6]  = 0; // $bits(shortreal member) rejected by slang
    r[7]  = $bits(v_usstr);
    r[8]  = $bits(v_ustime);
    r[9]  = 0; // $bits(chandle member) rejected by slang
    r[10] = 0; // $bits(realtime member) rejected by slang
    r[11] = $bits(v_pu);
    r[12] = $bits(v_uu);
    r[13] = $bits(v_nest);
    r[14] = $bits(v_arrmem);
    r[15] = $bits(v_pkenum);
    r[16] = $bits(v_afix);
    r[17] = $bits(v_adyn);
    r[18] = $bits(v_aq);
    r[19] = $bits(v_aaa);
    r[20] = $bits(v_a2d);
    r[21] = $bits(v_pkarr);
    r[22] = $bits(ebare_t);
    r[23] = $bits(ebased_t);
    r[24] = $bits(ps_t);
    r[25] = $bits(pu_t);
    r[26] = $bits(v_ps.c);
    r[27] = $bits(v_ps.d);
    r[28] = $bits(v_nest.inner);
    r[29] = $bits(v_afix[2]);
  end
endmodule
