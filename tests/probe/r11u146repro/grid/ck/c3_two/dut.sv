// § castKeyElabNetNoFile146
package q;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
endpackage
module dut import q::*; (output logic [7:0] o, output logic [7:0] p);
  localparam t_t P = t_t'{a: 4'h1, b: 4'h2};
  localparam t_t Q = t_t'{a: 4'h3, b: 4'h4};
  assign o = P;
  assign p = Q;
endmodule
