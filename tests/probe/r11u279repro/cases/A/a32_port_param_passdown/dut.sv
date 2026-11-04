// § structParamCaReadsPaValue279
package p;
  typedef struct packed { logic [7:0] key; logic [7:0] nonce; } s_t;
  typedef s_t a_t;
  localparam s_t D = 16'hbeef;
  localparam s_t D2 = 16'h1234;
  localparam s_t DP = '{key: 8'h12, nonce: 8'h34};
  localparam s_t DE = 16'hbe00 + 16'h00ef;
  localparam s_t DX = 16'hxxxx;
endpackage
module sub #(parameter p::s_t P = 16'h0) (output logic [15:0] o);
  assign o = P;
endmodule
module mid #(parameter p::s_t Q = p::D) (output logic [15:0] o);
  sub #(.P(Q)) u (.o(o));
endmodule
module dut (output logic [15:0] o);
  mid m (.o(o));
endmodule
