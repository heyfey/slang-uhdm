// § structMemberDefault414
package p;
typedef struct {
  int a = 7;
  bit x = 1'b1;
} q_t;
endpackage
module top ();
p::q_t w;
endmodule
