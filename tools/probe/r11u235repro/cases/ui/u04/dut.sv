// § unitClsAggTdLastWriter235
package p;
typedef struct { string path; int offset; } slice_t;
typedef struct packed { logic [3:0] a; logic b; } pk_t;
endpackage
import p::*;
class env;
  slice_t s;
endclass
module top;
  pk_t q;
endmodule
