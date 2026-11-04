// § unitClsAggTdLastWriter235
package p;
typedef struct packed { logic [3:0] a; logic b; } pk_t;
endpackage
package q;
typedef struct packed { logic [1:0] c; } qk_t;
endpackage
import p::*;
import q::*;
virtual class base; endclass
class env extends base;
  pk_t m;
endclass
interface ifc; pk_t s; endinterface
module top(output [4:0] o);
  pk_t s;
  qk_t t;
  ifc i();
  assign o = s;
endmodule
