// § structParamCaReadsPaValue279
package p;
  typedef struct packed { logic [7:0] key; logic [7:0] nonce; } s_t;
  localparam s_t D = 16'hbeef;
  localparam s_t D2 = 16'h1234;
  localparam logic [15:0] DL = 16'hcafe;
  localparam s_t DCAT = {8'hbe, 8'hef};
endpackage
module dut (output logic [15:0] o);
  parameter p::s_t P = p::DCAT;
  assign o = P;
endmodule
