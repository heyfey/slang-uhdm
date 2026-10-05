// § unitImpPaRhsActualFinal243v
// typed parameters with unsized based values: logic vector, bit, a package typedef, an implicit range, signed
package p;
  typedef logic [3:0] n_t;
  parameter logic [7:0] A = 'hff;
  parameter bit B = 'b1;
  parameter n_t C = 'h3;
  parameter [7:0] D = 'h5;
  parameter signed E = 'h5;
  parameter integer F = 'h9;
endpackage
import p::*;
class env;
  int v;
endclass
module top;
  env e;
endmodule
