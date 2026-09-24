package p;
  parameter int W = 8;
  typedef logic [W-1:0] k_t;
  typedef struct packed { k_t key; k_t nonce; } s_t;
  localparam s_t D = 16'hbeef;
endpackage
module leaf #(parameter int Width = 1, parameter logic [Width-1:0] RV = 0) ();
endmodule
module dut (output logic [15:0] o);
  parameter p::s_t P = p::D;
  leaf #(.Width(p::W), .RV(P.key)) u ();
  assign o = P;
endmodule
