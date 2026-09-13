package p;
  typedef struct packed {
    logic lock;
    logic [1:0] mode;
    logic exec;
    logic write;
    logic read;
  } s_t;
  parameter s_t P[16] = '{
    '{lock: 1'b0, mode: 2'b00, exec: 1'b0, write: 1'b0, read: 1'b0},
    '{lock: 1'b0, mode: 2'b00, exec: 1'b0, write: 1'b0, read: 1'b0},
    '{lock: 1'b0, mode: 2'b00, exec: 1'b0, write: 1'b0, read: 1'b0},
    '{lock: 1'b0, mode: 2'b00, exec: 1'b0, write: 1'b0, read: 1'b0},
    '{lock: 1'b0, mode: 2'b00, exec: 1'b0, write: 1'b0, read: 1'b0},
    '{lock: 1'b0, mode: 2'b00, exec: 1'b0, write: 1'b0, read: 1'b0},
    '{lock: 1'b0, mode: 2'b00, exec: 1'b0, write: 1'b0, read: 1'b0},
    '{lock: 1'b0, mode: 2'b00, exec: 1'b0, write: 1'b0, read: 1'b0},
    '{lock: 1'b0, mode: 2'b00, exec: 1'b0, write: 1'b0, read: 1'b0},
    '{lock: 1'b0, mode: 2'b00, exec: 1'b0, write: 1'b0, read: 1'b0},
    '{lock: 1'b0, mode: 2'b00, exec: 1'b0, write: 1'b0, read: 1'b0},
    '{lock: 1'b0, mode: 2'b00, exec: 1'b0, write: 1'b0, read: 1'b0},
    '{lock: 1'b0, mode: 2'b00, exec: 1'b0, write: 1'b0, read: 1'b0},
    '{lock: 1'b0, mode: 2'b00, exec: 1'b0, write: 1'b0, read: 1'b0},
    '{lock: 1'b0, mode: 2'b00, exec: 1'b0, write: 1'b0, read: 1'b0},
    '{lock: 1'b0, mode: 2'b00, exec: 1'b0, write: 1'b0, read: 1'b0}
  };
endpackage

module leaf import p::*; (input s_t a [16], output logic x);
  assign x = a[0].lock;
endmodule

module dut(output logic o);
  import p::*;
  leaf #() u (.a(P), .x(o));
endmodule
