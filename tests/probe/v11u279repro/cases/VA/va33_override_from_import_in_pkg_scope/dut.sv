// § structParamCaReadsPaValue279
package p;
  typedef struct packed { logic [7:0] key; logic [7:0] nonce; } s_t;
  localparam s_t D = 16'hbeef;
  localparam s_t D2 = 16'h1234;
endpackage
module sub #(parameter p::s_t P = 16'h0) (output logic [15:0] o);
  assign o = P;
endmodule
module dut (output logic [15:0] o, output logic [15:0] o2);
  sub #(p::D) u (.o(o));
  sub #(16'h00ff) v (.o(o2));
endmodule
