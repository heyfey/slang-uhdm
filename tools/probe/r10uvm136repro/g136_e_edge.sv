// r10uvm136 arm E — the EDGES of the packed-struct class property: packed
// ARRAYS over the struct, `type` parameters, parameterized / extended / nested
// / virtual classes, and a 3-deep typedef chain.  These are the cells the law
// must either MINT or deliberately FENCE.
package Edg2;
  typedef struct packed { bit [7:0] loBits; bit [7:0] hiBits; } span16_T;
  typedef union  packed { bit [15:0] flat; span16_T split; } wrap16_T;
  typedef span16_T span_L1;
  typedef span_L1  span_L2;
  typedef span_L2  span_L3;
  typedef span16_T [3:0] quadSpan_T;      // typedef of a PACKED ARRAY over it
  typedef struct packed { bit [1:0] mode; span16_T inner; } nestOuter_T;
  typedef enum bit [1:0] { M_A, M_B } modeSel_e;
  typedef struct packed { modeSel_e sel; bit [5:0] pad; } withEnum_T;

  virtual class AbstractHold9;
    span16_T e01_virtbase;
  endclass

  class BaseHold7;
    span16_T e02_base;
  endclass

  class DerivHold8 extends BaseHold7;
    wrap16_T e03_deriv;
  endclass

  class ParamHold #(type TP_T = span16_T, int WID = 4);
    TP_T        e04_typeparam;
    span16_T [1:0] e05_packedArr;
    quadSpan_T  e06_arrTypedef;
    span_L3     e07_chain3;
    nestOuter_T e08_nested;
    withEnum_T  e09_withenum;
    class InnerHold3;
      span16_T e10_innerclass;
    endclass
  endclass

  class UseParam2;
    ParamHold #(wrap16_T, 8) e11_specialized;
  endclass
endpackage

module etop;
  Edg2::DerivHold8 d8;
  Edg2::ParamHold #(Edg2::span16_T, 4) ph;
  Edg2::UseParam2 up;
  initial begin d8 = new(); ph = new(); up = new(); end
endmodule
