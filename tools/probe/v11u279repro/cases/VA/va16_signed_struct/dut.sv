// § structParamCaReadsPaValue279
package p;
  typedef struct packed { logic [7:0] key; logic [7:0] nonce; } s_t;
  typedef struct packed signed { logic [7:0] key; logic [7:0] nonce; } ss_t;
  localparam s_t D = 16'hbeef;
  localparam s_t D2 = 16'h1234;
  localparam logic [15:0] DL = 16'hcafe;
  localparam ss_t DS = 16'h8001;
endpackage
module dut (output logic [15:0] o);
  parameter p::ss_t P = p::DS;
  assign o = P;
endmodule
