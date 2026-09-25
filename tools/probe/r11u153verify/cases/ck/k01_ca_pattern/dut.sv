// § castKeyElabNetNoFile146
package q;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
endpackage
module dut import q::*; (output logic [7:0] o);
  assign o = t_t'{a: 4'h1, b: 4'h2};
endmodule
