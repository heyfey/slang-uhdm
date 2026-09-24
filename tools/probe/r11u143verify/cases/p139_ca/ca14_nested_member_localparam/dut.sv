// § caLhsDefNetUnlessOpRhs139
// case ca14: a nested member of a struct localparam as the right-hand side
module top(output logic o);
  typedef struct packed { logic x; logic z; } in_t;
  typedef struct packed { in_t i; logic w; } out_t;
  localparam out_t P = '{i: '{x: 1'b0, z: 1'b1}, w: 1'b0};
  assign o = P.i.z;
endmodule
