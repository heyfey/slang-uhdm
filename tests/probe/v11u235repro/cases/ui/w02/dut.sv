// § unitClsAggTdLastWriter235
package p;
typedef struct packed { logic [3:0] a; logic b; } pk_t;
typedef union packed { logic [4:0] u; pk_t s; } un_t;
endpackage
import p::*;
class zeta; int q; endclass
class alpha; pk_t m; endclass
module top(output [4:0] o);
  un_t s;
  assign o = s.u;
endmodule
