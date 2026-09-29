// § enumClsWriterUnitScopeOnly219 — a class nested in a $unit class lists the enum; the outer $unit class lists it too; a module imports the package
package p;
  typedef enum logic [1:0] {N0, N1, N2} n_t;
endpackage
import p::*;
class outer_c;
  n_t a;
  class inner_c;
    n_t b;
  endclass
endclass
module top(output int o);
  import p::*;
  n_t v;
  assign v = N1;
  assign o = int'(v);
endmodule
