package p;
  typedef struct packed {
    logic m0;
    logic m1;
  } s_t;
  parameter s_t A = '{m0: 1'b1, m1: 1'b0};
  parameter s_t B = '{m0: 1'b0, m1: 1'b1};
endpackage

module leaf import p::*; #(parameter s_t P[2] = '{A, A}) (output logic x);
  assign x = P[0].m0 ^ P[1].m1;
endmodule

module dut(output logic o);
  import p::*;
  leaf #(.P('{A, B})) u (.x(o));
endmodule
