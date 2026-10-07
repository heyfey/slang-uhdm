// § structParamCaReadsPaValue279
package p;
  typedef struct packed { logic [7:0] key; logic [7:0] nonce; } s_t;
  localparam s_t D = 16'hbeef;
  localparam s_t D2 = 16'h1234;
  localparam logic [15:0] DL = 16'hcafe;
endpackage
module dut #(parameter p::s_t Q = 16'h1111, parameter p::s_t P = Q) (output logic [15:0] o);
  assign o = P;
endmodule
