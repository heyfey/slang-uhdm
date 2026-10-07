// § structParamCaReadsPaValue279
package p;
  typedef struct packed { logic [7:0] key; logic [7:0] nonce; } s_t;
  localparam s_t D = 16'hbeef;
  localparam s_t D2 = 16'h1234;
  localparam s_t DCAST = s_t'(16'hbeef);
  localparam logic [15:0] DL = 16'hcafe;
endpackage
module dut (output logic [15:0] o);
  parameter p::s_t P = p::DCAST;
  assign o = P;
endmodule
