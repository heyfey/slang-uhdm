package p;
  typedef enum logic [1:0] {
    M_OFF = 2'b00,
    M_TOR = 2'b01
  } mode_e;

  typedef struct packed {
    logic q;
  } sub_t;

  typedef struct packed {
    logic m0;
    logic m1;
  } s_t;

  parameter s_t P[3] = '{
    '{m0: 1'b0, m1: 1'b0},
    '{m0: 1'b0, m1: 1'b0},
    '{m0: 1'b0, m1: 1'b0}
  };
endpackage

module leaf import p::*; (input s_t a [3], output logic x);
  assign x = a[0].m0;
endmodule

module dut(output logic o);
  import p::*;
  leaf #() u (.a(P), .x(o));

endmodule
