// v136 arm E — EDGES: parameterized class, type parameter, nested class,
// struct-in-struct, struct-with-enum, packed arrays (the FENCE), 2-D.
package Pk_Edge;
  typedef enum bit [1:0] { E_A, E_B, E_C } tri_e;
  typedef struct packed { bit [3:0] inner1; bit [3:0] inner2; } innerSpan_S;
  typedef struct packed { innerSpan_S nestA; bit [7:0] flatB; } outerSpan_S;
  typedef struct packed { tri_e tagC; bit [5:0] restD; }        tagSpan_S;

  class ParamProp #(parameter int NWIDE = 4, type TFACE = innerSpan_S);
    TFACE        e01_typeParam;
    innerSpan_S  e02_fixedFace;
    bit [NWIDE-1:0] e03_parmvec;
  endclass

  class Outer;
    outerSpan_S e04_nested;
    tagSpan_S   e05_withEnum;
    class Inner;
      innerSpan_S e06_innerProp;
    endclass
    Inner       e07_innerHandle;
  endclass

  class FenceArm;                 // the deliberate FENCE population
    innerSpan_S  e08_pastruct [1:0];      // PACKED array over a struct
    innerSpan_S  e09_pastruct2d [1:0][2:0];
    tri_e        e10_paenum [1:0];
    bit   [1:0][7:0] e11_pabit;
    logic [1:0][3:0] e12_palogic;
  endclass

  typedef ParamProp#(8, tagSpan_S) spec_t;
  class SpecUser;
    spec_t       e13_specHandle;
    ParamProp#(3) e14_defSpec;
  endclass
endpackage
