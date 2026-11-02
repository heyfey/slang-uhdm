// § unitImpTransitiveTds464 (struct and enum typedefs reached transitively)
package a;
  typedef struct packed { logic [3:0] x; logic y; } s_t;
  typedef enum logic [1:0] { R, G, B } e_t;
endpackage
package m;
  import a::*;
endpackage
import m::*;
module top(input logic [1:0] i, output logic [1:0] o);
  assign o = i;
endmodule
