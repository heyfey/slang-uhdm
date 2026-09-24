// § impLhsCloneArrayTsOwnCopy140
package q;
  typedef struct packed { logic [3:0] a; } s_t;
endpackage
package pk;
  parameter q::s_t A[2] = '{'{a: 4'h1}, '{a: 4'h2}};
endpackage
module dut import pk::*; #(parameter int W = 1) (input logic sel, output logic [3:0] o);
  assign o = A[sel].a;
endmodule
