// § castKeyElabNetNoFile146
package q;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
endpackage
module dut import q::*; (output logic [7:0] o);
  localparam t_t P = t_t'{a: 4'h1, default: 4'h0};
  assign o = P;
endmodule
