// r10svs6 arm b4 — the PROPERTY QUALIFIERS on a fixed-size unpacked array.
// The brief flags one reading to decode rather than transcribe: BOTH SVSwitch
// witnesses carry `vpiRandType:1` and NEITHER is written `rand`.  vpiRandType 1
// is vpiNotRand, i.e. the DEFAULT stamp on an array_var, so the question this arm
// answers is whether a WRITTEN `rand` moves it to 2 (and `randc` to 3) and
// whether `vpiIsRandomized` rides along — exactly as the dynamic-array arm
// already does — and what `static` / `local` / `protected` / `const` do to
// vpiAutomatic and vpiVisibility.
class Hand4;
  int id;
endclass

class b4_cls;
  rand int c01_rand[4];
  randc int c02_randc[4];
  static int c03_static[4];
  local int c04_local[4];
  protected int c05_prot[4];
  const int c06_const[4] = '{1, 2, 3, 4};
  static local int c07_statloc[4];
  rand local int c08_randloc[4];
  local static int c09_locstat[4];
  protected rand int c10_protrand[4];
  int c11_initpat[4] = '{1, 2, 3, 4};
  rand Hand4 c12_randhand[4];
  // The DYNAMIC/QUEUE twins of the `const` cell: § constClassPropIsConstantVariable27
  // is stamped in the SHARED array arm, so whether golden puts it on a DYNAMIC
  // array property too has to be measured, not assumed.
  const int c15_constq[$] = {1, 2};
  const int c16_constdyn[] = '{1, 2};
endclass

class b4_par #(type T = int);
  rand T c13_randtp[4];
  local T c14_loctp[4];
endclass

module b4_top;
  int m03_static[4];
  int m11_initpat[4] = '{1, 2, 3, 4};
  b4_cls c;
  b4_par #(int) p;
endmodule
