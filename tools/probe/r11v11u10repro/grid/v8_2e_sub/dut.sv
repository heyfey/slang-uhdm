package p;
  typedef struct packed {
    logic q;
  } sub_t;
  typedef struct packed {
    sub_t m0;
    logic m1;
  } s_t;
  parameter s_t P[2] = '{'{m0: '{q: 1'b1}, m1: 1'b0}, '{m0: '{q: 1'b0}, m1: 1'b1}};
endpackage

module leaf import p::*; (input s_t a [2], output logic x);
  assign x = a[0].m1;
endmodule

module dut(output logic o);
  import p::*;
  leaf #() u (.a(P), .x(o));
endmodule
