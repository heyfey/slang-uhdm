// § structParamCaReadsPaValue279
package p;
  typedef struct packed { logic [7:0] key; logic [7:0] nonce; } s_t;
  localparam s_t D = 16'hbeef;
  localparam s_t D2 = 16'h1234;
endpackage
package p2;
  localparam p::s_t X = p::D2;
endpackage
module dut (output logic [15:0] o);
  parameter p::s_t P = p2::X;
  assign o = P;
endmodule
