// § dupImportSameValueKeeps252
package p;
typedef enum logic [1:0] {A0, A1, A2} e_t;
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
parameter e_t E = A2;
parameter s_t SP = '{a: 4'h3, b: 4'h5};
parameter int W = 4;
endpackage
import p::*;
module top(output logic [7:0] o, output logic [1:0] e);
  assign o = SP;
  assign e = E;
endmodule
