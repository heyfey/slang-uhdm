// § unitClsAggTdLastWriter235
package p;
typedef struct packed { logic [3:0] a; logic b; } pk_t;
endpackage
package q;
import p::*;
class qc;
  pk_t m;
endclass
endpackage
import p::*;
module top;
  pk_t r;
endmodule
