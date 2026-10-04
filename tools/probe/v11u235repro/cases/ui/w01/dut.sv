// § unitClsAggTdLastWriter235
package p;
typedef logic [7:0] byte_t;
typedef struct packed { byte_t a; logic b; } pk_t;
class pc; int z; endclass
endpackage
import p::*;
class env;
  byte_t v;
  pk_t k;
  pc h;
endclass
module top(output [8:0] o);
  pk_t s;
  byte_t w;
  assign o = s;
endmodule
