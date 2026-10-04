// § unitClsAggTdLastWriter235
package p;
typedef struct packed { logic [3:0] a; logic b; } pk_t;
endpackage
import p::*;
module top;
  class mc;
    pk_t m;
  endclass
  pk_t r;
endmodule
