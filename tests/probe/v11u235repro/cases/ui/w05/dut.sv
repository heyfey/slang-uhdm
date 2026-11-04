// § unitClsAggTdLastWriter235
package p;
typedef struct packed { logic [3:0] a; logic b; } pk_t;
typedef struct { int x; string s; } up_t;
endpackage
import p::*;
class env #(type T=int);
  T m;
endclass
typedef env#(pk_t) env_pk;
module top(output [4:0] o);
  pk_t s;
  assign o = s;
endmodule
