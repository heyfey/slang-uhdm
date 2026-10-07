// § structParamCaReadsPaValue279
package p;
  typedef struct packed { logic [7:0] key; logic [7:0] nonce; } s_t;
  localparam s_t D = 16'hbeef;
  localparam s_t D2 = 16'h1234;
endpackage
module sub #(parameter p::s_t P = p::D) (output logic [15:0] o, output logic [15:0] o2);
  assign o = P;
  if (1) begin : g
    assign o2 = P;
  end
endmodule
module dut (output logic [15:0] o, output logic [15:0] o2);
  sub u (.o(o), .o2(o2));
endmodule
