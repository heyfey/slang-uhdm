// § structParamCaReadsPaValue279
package p;
  typedef struct packed { logic [7:0] key; logic [7:0] nonce; } s_t;
  localparam s_t D = 16'hbeef;
  localparam s_t D2 = 16'h1234;
endpackage
module sub #(parameter p::s_t P = p::D) (output p::s_t o);
  assign o = P;
endmodule
module dut (output p::s_t o, output p::s_t o2);
  sub u (.o(o));
  sub #(.P(p::D2)) v (.o(o2));
endmodule
