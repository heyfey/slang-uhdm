// r10svs6 VERIFIER arm v2 — EMPTY PRODUCT CELLS on the CLASS-KIND and
// QUALIFIER x INITIALIZER axes.  The brief named "class kind
// (parameterized/nested/interface-declared)" as an axis; the implementer's grid
// measured PARAMETERIZED only (b4 c13/c14).  Nested, module-declared,
// interface-declared, package-declared, EXTENDED and VIRTUAL classes are all
// unmeasured, and so are the REPLICATED and STRUCTURED initializer patterns —
// the new § fixedClassPropIsArrayVar6 INITIALIZER HALF accepts all three
// ExpressionKinds but the grid exercised only the simple one.

package v2_pkg;
  class v2_inpkg;                       // class declared in a PACKAGE
    int p01_arr[4];
    int p02_init[4] = '{1, 2, 3, 4};
  endclass
endpackage

interface v2_if;
  logic clk;
  class v2_inif;                        // class declared in an INTERFACE
    int i01_arr[4];
  endclass
  modport MP(input clk);
endinterface

class v2_outer;                         // NESTED class
  int n01_arr[4];
  class v2_inner;
    int n02_arr[4];
    int n03_2d[2][2];
  endclass
endclass

virtual class v2_virt;                  // VIRTUAL class
  int w01_arr[4];
  protected int w02_prot[4];
endclass

class v2_base;                          // BASE / DERIVED pair
  int b01_arr[4];
  local int b02_loc[4];
endclass

class v2_der extends v2_base;
  int d01_arr[4];
endclass

class v2_init;                          // the three assignment-pattern kinds
  int e01_simple[4] = '{1, 2, 3, 4};
  int e02_repl[4]   = '{4{7}};
  int e03_struct[4] = '{default: 0};
  static int e04_statinit[4] = '{1, 2, 3, 4};
  const int e05_constinit[4] = '{1, 2, 3, 4};
  rand int e06_rand2d[2][2];
  local static int e07_locstat[4];
  protected static int e08_protstat[4];
  int e09_noinit[4];                    // control: same class, no initializer
endclass

module v2_top;
  int m_e01_simple[4] = '{1, 2, 3, 4};
  int m_e02_repl[4]   = '{4{7}};
  int m_e03_struct[4] = '{default: 0};
  v2_pkg::v2_inpkg a;
  v2_outer b;
  v2_outer::v2_inner c;
  v2_der d;
  v2_init e;
endmodule
