package p;
  typedef struct packed {
    logic q;
  } sub_t;
  typedef struct packed {
    sub_t m0;
    logic m1;
  } s_t;
endpackage

module leaf import p::*; #(parameter s_t P[2] = '{'{m0: '{q: 1'b1}, m1: 1'b0}, '{m0: '{q: 1'b0}, m1: 1'b1}}) (output logic x);
  assign x = P[0].m1 ^ P[1].m0.q;
endmodule

module dut(output logic o);
  leaf #() u (.x(o));
endmodule
