package p;
  typedef struct packed {
    logic m0;
    logic m1;
  } s_t;
  parameter s_t P[2] = '{'{m0: 1'b1, m1: 1'b0}, '{m0: 1'b0, m1: 1'b1}};
endpackage

module dut import p::*; (output logic o);
  assign o = P[0].m0 ^ P[1].m1;
endmodule
