// § constPathBaseAnyKind146
module top(output logic [7:0] o);
  typedef struct { int unsigned W; } c_t;
  localparam c_t C = '{W: 8};
  logic [C.W-1:0] x;
  assign x = 8'd5;
  assign o = x;
endmodule
