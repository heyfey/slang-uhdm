// § structParamCaReadsPaValue279
package p;
  typedef struct packed { logic [7:0] key; logic [7:0] nonce; } s_t;
  localparam s_t D = 16'hbeef;
  localparam s_t D2 = 16'h1234;
  localparam logic [15:0] DL = 16'hcafe;
endpackage
module sub #(parameter p::s_t P = p::D) (output logic [15:0] o);
  assign o = P;
endmodule
module dut (output logic [31:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    sub u (.o(o[i*16 +: 16]));
  end
endmodule
