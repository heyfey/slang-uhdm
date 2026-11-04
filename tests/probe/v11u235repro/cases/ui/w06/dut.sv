// § unitClsAggTdLastWriter235
package p;
typedef struct packed { logic [3:0] a; logic b; } pk_t;
endpackage
import p::*;
module top(output [4:0] o);
  pk_t s;
  assign o = s;
endmodule
