// § topNestedArrElemTopTwin269 (control: an enum element array beside a struct member)
package p;
  typedef struct packed { logic [3:0] q; } addr_t;
  typedef enum logic [1:0] { A0, A1, A2 } e_t;
  typedef struct packed { addr_t addr; e_t [1:0] es; } reg2hw_t;
endpackage
module sub(input p::e_t d, output p::e_t q); assign q = d; endmodule
module regtop(input p::e_t d, output p::reg2hw_t reg2hw);
  import p::*;
  sub u0(.d(d), .q(reg2hw.es[0]));
endmodule
module top(input p::e_t d, output p::reg2hw_t r);
  regtop u_reg(.d(d), .reg2hw(r));
endmodule
