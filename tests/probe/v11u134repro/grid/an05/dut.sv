// § memberAnonUnionAtKeyword134
module top(input logic [3:0] i, output logic [3:0] o);
  typedef struct packed {
    logic a;
    union   packed
    { logic [3:0] w; logic [3:0] z; }   u1, u2;
  } s_t;
  s_t s;
  assign s = {1'b0, i, i};
  assign o = s.u1.w ^ s.u2.z;
endmodule
