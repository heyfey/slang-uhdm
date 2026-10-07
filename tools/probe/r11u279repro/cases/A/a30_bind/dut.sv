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
module chk #(parameter p::s_t P = p::D) (input logic [15:0] i, output logic [15:0] o);
  assign o = P;
endmodule
module tgt (input logic [15:0] i);
endmodule
module dut (input logic [15:0] i);
  tgt t (.i(i));
  bind tgt chk c (.i(i), .o());
endmodule
