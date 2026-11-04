// § structParamCaReadsPaValue279
package p;
  typedef struct packed { logic [7:0] key; logic [7:0] nonce; } s_t;
  typedef union packed { logic [15:0] w; s_t s; } u_t;
  localparam s_t D = 16'hbeef;
  localparam s_t D2 = 16'h1234;
  localparam s_t DP = '{key: 8'h12, nonce: 8'h34};
  localparam u_t DU = 16'h5a5a;
endpackage
module dut (output logic [15:0] o, output logic [15:0] o2);
  parameter p::s_t P = p::D;
  assign o = P;
  assign o2 = P;
endmodule
