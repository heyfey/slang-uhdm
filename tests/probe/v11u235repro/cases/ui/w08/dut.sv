// § unitClsAggTdLastWriter235
package p;
typedef logic [7:0] b_t;
typedef struct packed { b_t a; b_t c; logic [1:0] d; } pk_t;
typedef struct { b_t x; int y; } up_t;
endpackage
import p::*;
class env;
  pk_t m;
  up_t u;
  function void f(pk_t a); endfunction
endclass
class beta;
  up_t u2;
endclass
module top(output [17:0] o);
  pk_t s;
  assign o = s;
endmodule
