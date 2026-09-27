// § importNetTsToInitEnd183 (a struct-typed package variable with a multi-line initializer, an enum variable)
package p;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  typedef enum logic [1:0] { A, B, C } e_t;
  s_t sv = '{a: 4'h1,
             b: 4'h2};
  e_t ev = B;
  logic [3:0] lv = 4'h3;
endpackage
module top(output logic [7:0] o);
  import p::*;
  assign o = sv;
endmodule
