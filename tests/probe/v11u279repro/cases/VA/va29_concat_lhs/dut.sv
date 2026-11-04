// § structParamCaReadsPaValue279
package p;
  typedef struct packed { logic [7:0] key; logic [7:0] nonce; } s_t;
  localparam s_t D = 16'hbeef;
  localparam s_t D2 = 16'h1234;
endpackage
module dut (output logic [7:0] o, output logic [7:0] o2);
  parameter p::s_t P = p::D;
  assign {o, o2} = P;
endmodule
