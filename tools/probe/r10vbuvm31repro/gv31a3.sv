// v31a3 — ELEMENT-TYPE matrix: enums (base-less / based), packed struct/union,
// unpacked struct, typedef'd, class handle, nested patterns.
package v31p3;
  typedef enum { E_A, E_B, E_C } e_nobase_t;
  typedef enum bit [2:0] { F_A, F_B, F_C } e_based_t;
  typedef struct packed { bit [3:0] a; bit [3:0] b; } ps_t;
  typedef union  packed { bit [7:0] u; ps_t s; } pu_t;
  typedef struct { int a; string b; } us_t;
  typedef int    myint_t;
  typedef logic [5:0] v6_t;

  e_nobase_t pe_d[]        = '{E_A, E_B};
  e_nobase_t pe_aa[string] = '{default: E_A};
  e_based_t  pf_d[]        = '{F_A, F_B};
  ps_t       pps_d[]       = '{'{1, 2}, '{3, 4}};
  ps_t       pps_aa[string]= '{default: '{1, 2}};
  pu_t       ppu_d[]       = '{8'h5, 8'h6};
  us_t       pus_d[]       = '{'{a: 1, b: "x"}};
  myint_t    pmi_d[]       = '{1, 2};
  v6_t       pv6_d[]       = '{1, 2};
  int        pnest[][]     = '{'{1, 2}, '{3, 4}};
endpackage

module v31m3;
  import v31p3::*;
  e_nobase_t me_d[]        = '{E_A, E_B};
  e_nobase_t me_aa[string] = '{default: E_A};
  e_based_t  mf_d[]        = '{F_A, F_B};
  ps_t       mps_d[]       = '{'{1, 2}, '{3, 4}};
  ps_t       mps_aa[string]= '{default: '{1, 2}};
  us_t       mus_d[]       = '{'{a: 1, b: "x"}};
  v6_t       mv6_d[]       = '{1, 2};
  int        mnest[][]     = '{'{1, 2}, '{3, 4}};

  class v31c3;
    e_nobase_t ce_d[]        = '{E_A, E_B};
    e_nobase_t ce_aa[string] = '{default: E_A};
    e_based_t  cf_d[]        = '{F_A, F_B};
    ps_t       cps_d[]       = '{'{1, 2}, '{3, 4}};
    ps_t       cps_aa[string]= '{default: '{1, 2}};
    pu_t       cpu_d[]       = '{8'h5, 8'h6};
    us_t       cus_d[]       = '{'{a: 1, b: "x"}};
    v6_t       cv6_d[]       = '{1, 2};
    int        cnest[][]     = '{'{1, 2}, '{3, 4}};
    ps_t       cps_pk        = '{default: 0};
  endclass

  class v31h3;
    int x;
  endclass
  class v31c3b;
    v31h3 ch_d[]        = '{null, null};
    v31h3 ch_aa[string] = '{default: null};
  endclass
endmodule
