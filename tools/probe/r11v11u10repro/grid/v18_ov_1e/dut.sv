package p;
  typedef struct packed {
    logic m0;
    logic m1;
  } s_t;
endpackage

module leaf import p::*; #(parameter s_t P[1] = '{'{m0: 1'b0, m1: 1'b0}}) (output logic x);
  assign x = P[0].m0 ^ P[0].m1;
endmodule

module dut(output logic o);
  import p::*;
  leaf #(.P('{'{m0: 1'b1, m1: 1'b0}})) u (.x(o));
endmodule
