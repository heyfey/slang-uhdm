// § structParamCaReadsPaValue279
package p;
  typedef struct packed { logic [7:0] key; logic [7:0] nonce; } s_t;
  localparam s_t D = 16'hbeef;
  localparam s_t D2 = 16'h1234;
endpackage
interface ifc; logic [15:0] w; endinterface
module sub #(parameter p::s_t P = p::D) (ifc i);
  assign i.w = P;
endmodule
module dut (output logic [15:0] o);
  ifc u();
  sub s (.i(u));
  assign o = u.w;
endmodule
