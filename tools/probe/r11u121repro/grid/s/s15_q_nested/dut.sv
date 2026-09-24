package nq;
  typedef struct packed { logic [7:0] x; } in_t;
  typedef struct packed { in_t i; logic [3:0] y; } out_t;
  localparam out_t N = '{i: '{x: 8'hA5}, y: 4'h3};
endpackage
module top (output logic [7:0] o);
  assign o = nq::N.i.x[6:1];
endmodule
