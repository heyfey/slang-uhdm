// § structParamCaReadsPaValue279
package p;
  typedef struct packed { logic [7:0] key; logic [7:0] nonce; } s_t;
  localparam s_t D = 16'hbeef;
  localparam s_t D2 = 16'h1234;
  localparam s_t DE = 16'hbe00 + 16'h00ef;
  localparam logic [15:0] DL = 16'hcafe;
endpackage
module dut (output logic [15:0] o);
  parameter p::s_t P = p::DE;
  assign o = P;
endmodule
