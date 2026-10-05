// § clsPropElemAliasName247
package p;
  typedef struct packed { bit [3:0] a; } s_t;
  typedef enum bit [1:0] {X, Y} e_t;
  class q;
    s_t sq[$];
    e_t eq[$];
    s_t sa[int];
  endclass
endpackage
module top;
  import p::*;
  q x;
endmodule
