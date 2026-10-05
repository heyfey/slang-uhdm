// § impArrParamTsOwnRanges242
// A packed-struct array and a package-qualified int array read with no import.
package hp;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  parameter s_t S [2] = '{'{a: 4'h1, b: 4'h2}, '{a: 4'h3, b: 4'h4}};
  parameter int Q [2] = '{9, 10};
endpackage
module m2 import hp::*; (input logic i, output logic [3:0] o);
  assign o = S[i].b;
endmodule
module m3 (input logic i, output int o);
  assign o = hp::Q[i];
endmodule
module top (input logic i, output logic [3:0] o2, output int o3);
  m2 u2 (.i(i), .o(o2));
  m3 u3 (.i(i), .o(o3));
endmodule
