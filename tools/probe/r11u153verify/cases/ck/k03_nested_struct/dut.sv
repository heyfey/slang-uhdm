// § castKeyElabNetNoFile146
package q;
  typedef struct packed { logic [1:0] x; logic [1:0] y; } s_t;
  typedef struct packed { s_t a; logic [3:0] b; } t_t;
endpackage
module dut import q::*; (output logic [7:0] o);
  localparam t_t P = t_t'{a: s_t'{x: 2'd1, y: 2'd2}, b: 4'h3};
  assign o = P;
endmodule
