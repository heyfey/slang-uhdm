// § structParamCaReadsPaValue279
package p;
  typedef struct packed { logic [7:0] key; logic [7:0] nonce; } s_t;
  localparam s_t D = 16'hbeef;
  localparam s_t D2 = 16'h1234;
  localparam logic [15:0] DL = 16'hcafe;
endpackage
module dut (output logic [15:0] o, output logic [15:0] o2);
  parameter p::s_t P = p::D;
  assign o = P;
  for (genvar i = 0; i < 1; i++) begin : g
    assign o2 = P;
  end
endmodule
