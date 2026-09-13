package p;
  typedef struct packed {
    logic m0;
    logic m1;
  } s_t;
  parameter s_t P[2] = '{'{m0: 1'b1, m1: 1'b0}, '{m0: 1'b0, m1: 1'b1}};
endpackage

module leaf import p::*; (input s_t a [2], output logic x);
  assign x = a[0].m0;
endmodule

module dut(output logic o1, output logic o2);
  import p::*;
  leaf #() u1 (.a(P), .x(o1));
  leaf #() u2 (.a(P), .x(o2));
endmodule
