// § unitClsAggTdLastWriter235
package p;
typedef struct packed { logic [3:0] a; logic b; } in_t;
typedef struct packed { in_t i; logic c; } out_t;
endpackage
import p::*;
class env;
  out_t o;
endclass
module top;
  out_t r;
endmodule
