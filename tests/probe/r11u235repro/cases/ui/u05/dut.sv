// § unitClsAggTdLastWriter235
package p;
typedef union packed { logic [7:0] b; logic [1:0][3:0] n; } u_t;
typedef enum logic [1:0] {A, B} e_t;
endpackage
import p::*;
class zz_c;
  int x;
endclass
class aa_c;
  int y;
endclass
module top;
  u_t q;
endmodule
