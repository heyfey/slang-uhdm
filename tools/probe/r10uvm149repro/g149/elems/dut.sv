// r10uvm149 arm B -- ELEMENT KINDS under a QUEUE dimension.
package Kappa_pkg;
  typedef enum bit [1:0] { RED = 2'd1, GREEN = 2'd2 } paint_e;
  typedef logic [11:0] wide_t;
  typedef struct { int inner_a; byte inner_b; } nested_t;
  class handleClass;
    int carried;
  endclass
endpackage

package Omega_pkg;
  import Kappa_pkg::*;
  typedef struct {
    string          strQ[$];
    int             intQ[$];
    bit [5:0]       vecQ[$];
    paint_e         enumQ[$];
    nested_t        nestQ[$];
    wide_t          tdefQ[$];
    handleClass     clsQ[$];
    real            realQ[$];
    Kappa_pkg::nested_t plainNest;
  } elemkinds_t;
  elemkinds_t theElems;
endpackage

module elems_top;
  import Omega_pkg::*;
  elemkinds_t e1, e2;
  initial e1.plainNest.inner_a = 1;
endmodule
