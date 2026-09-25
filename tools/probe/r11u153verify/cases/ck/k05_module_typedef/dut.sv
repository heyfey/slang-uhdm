// § castKeyElabNetNoFile146
module dut (output logic [7:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
  localparam t_t P = t_t'{a: 4'h1, b: 4'h2};
  assign o = P;
endmodule
