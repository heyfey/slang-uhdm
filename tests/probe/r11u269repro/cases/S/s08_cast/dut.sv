// § selLhsOpFoldFresh269 (control: a cast Rhs keeps the operation)
package fp;
  localparam int AllPagesW = 9;
endpackage
module fc import fp::*; #(parameter int P = 3) (output logic [8:0] w, output logic [8:0] v, input logic [8:0] a);
  localparam int LW = 4;
  logic [3:0] arr [2];
  typedef struct packed { logic [8:0] f; } s_t;
  s_t s;
  assign w[3:0] = 4'(P);
  assign v = arr[0] ^ s.f[3:0];
endmodule
module top(output logic [8:0] w, output logic [8:0] v, input logic [8:0] a);
  fc #(.P(5)) u_fc(.w(w), .v(v), .a(a));
endmodule
