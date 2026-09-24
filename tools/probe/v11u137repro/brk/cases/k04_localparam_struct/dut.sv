// § structParamPathBaseAtMember137
module top(output logic o);
  typedef struct packed { int W; int N; } cfg_t;
  localparam cfg_t C = '{W: 5, N: 2};
  logic [C.W-1:0] x;
  logic y [C.N];
  assign o = x[0] ^ y[0];
endmodule
