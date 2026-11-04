// § unitImpTransitiveTds464 (a struct typedef reached transitively, used in the module)
package a;
  typedef struct packed { logic [3:0] x; logic y; } a_s;
endpackage
package m;
  import a::*;
endpackage
import m::*;
module top(input logic [4:0] i, output logic [4:0] o);
  a::a_s s;
  assign s = i;
  assign o = s;
endmodule
