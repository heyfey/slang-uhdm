package p;
  typedef struct packed {
    logic m0;
  } s_t;
  parameter s_t P[2][2] = '{'{'{m0: 1'b0}, '{m0: 1'b1}}, '{'{m0: 1'b1}, '{m0: 1'b0}}};
endpackage

module leaf import p::*; (input s_t a [2][2], output logic x);
  assign x = a[0][0].m0;
endmodule

module dut(output logic o);
  import p::*;
  leaf #() u (.a(P), .x(o));
endmodule
