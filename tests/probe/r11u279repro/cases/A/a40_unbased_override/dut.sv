// § structParamCaReadsPaValue279
package p;
  typedef struct packed { logic [7:0] key; logic [7:0] nonce; } s_t;
endpackage
module sub #(parameter p::s_t P = 16'h1) (output logic [15:0] o);
  assign o = P;
endmodule
module dut (output logic [15:0] o);
  sub #(.P('0)) u (.o(o));
endmodule
