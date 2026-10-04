// § clsTdClsEnumMemberShares235
package p;
class pol #(int N=1);
  typedef enum {X, Y} rs_e;
  typedef struct { rs_e state; bit [N-1:0] v; } si_t;
  si_t a;
endclass
class user;
  pol#(2)::si_t b;
  typedef struct { pol#(3)::rs_e e; } us_t;
  us_t c;
endclass
endpackage
module top;
endmodule
