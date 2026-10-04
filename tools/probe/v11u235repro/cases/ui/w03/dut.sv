// § unitClsAggTdLastWriter235
package p;
typedef struct packed { logic [3:0] a; logic b; } pk_t;
endpackage
class env;
  p::pk_t m;
endclass
module top(output [4:0] o);
  import p::*;
  pk_t s;
  assign o = s;
endmodule
