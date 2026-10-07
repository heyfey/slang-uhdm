// § structParamCaReadsPaValue279
package p;
  typedef struct packed { logic [7:0] key; logic [7:0] nonce; } s_t;
endpackage
module dut (output logic [15:0] o);
  parameter p::s_t P = '1;
  assign o = P;
endmodule
