// vbuvm7 arm P — WILDCARD-IMPORTED package variable as the collapse base.
package pkP;
  typedef struct { int used; } stP_t;
  stP_t parr[4];
  int   pi;
endpackage
module topP;
  import pkP::*;
  initial begin
    parr[1].used++;      // P1 unqualified imported package variable
    pi++;                // P2 control
  end
endmodule
