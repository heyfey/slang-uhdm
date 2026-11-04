// § castKeyElabNetNoFile146
package q;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
endpackage
module sub import q::*; (output logic [7:0] o);
  localparam t_t P = t_t'{a: 4'h1, b: 4'h2};
  assign o = P;
endmodule
module dut(output logic [7:0] o);
  sub u(.o(o));
endmodule
