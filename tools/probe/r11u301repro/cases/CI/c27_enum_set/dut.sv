// § caInsideRhsClonesCell301
module dut (input logic [1:0] a, output logic o);
  typedef enum logic [1:0] { A0, A1, A2 } e_t;
  e_t e;
  assign e = e_t'(a);
  assign o = e inside {A1, A2};
endmodule
