package p;
  typedef struct packed {
    logic m0;
    logic m1;
  } s_t;
  parameter s_t P[1] = '{'{default: 1'b1}};
endpackage

module leaf import p::*; (input s_t a [1], output logic x);
  assign x = a[0].m0;
endmodule

module dut(output logic o);
  import p::*;
  leaf #() u (.a(P), .x(o));
endmodule
