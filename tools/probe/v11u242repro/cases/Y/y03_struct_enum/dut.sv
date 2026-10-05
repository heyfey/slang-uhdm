// § impArrParamTsOwnRanges242
// Arrays of an enum and of a packed struct, an explicit import, and a package-qualified read with no import.
package hp;
  typedef enum logic [1:0] {X0, X1, X2} e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  parameter e_t E [3] = '{X0, X2, X1};
  parameter s_t S [2] = '{'{a: 4'h1, b: 4'h2}, '{a: 4'h3, b: 4'h4}};
  parameter int Q [2] = '{9, 10};
endpackage
module m1 import hp::E; (input logic [1:0] i, output hp::e_t o);
  assign o = E[i];
endmodule
module m2 import hp::*; (input logic i, output logic [3:0] o);
  assign o = S[i].b;
endmodule
module m3 (input logic i, output int o);
  assign o = hp::Q[i];
endmodule
module top (input logic [1:0] i, output hp::e_t o1, output logic [3:0] o2, output int o3);
  m1 u1 (.i(i), .o(o1));
  m2 u2 (.i(i[0]), .o(o2));
  m3 u3 (.i(i[0]), .o(o3));
endmodule
