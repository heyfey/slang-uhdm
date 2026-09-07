// r10vearl114 shared package for the verifier arms.
package pv114;
  typedef enum logic [1:0] {VE0, VE1, VE2} ve_t;
  typedef struct packed {
    logic       v;
    ve_t        op;
    logic [7:0] d;
  } vs_t;
  typedef struct packed {
    vs_t        inner;
    logic [3:0] tag;
  } vn_t;
endpackage
