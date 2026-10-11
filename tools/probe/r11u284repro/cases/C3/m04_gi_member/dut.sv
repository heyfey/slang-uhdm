// § genCaCatMemberInst284
module dut(input logic a, output logic [31:0] o);
  localparam logic [63:0] P = 1;
  typedef struct packed { logic [15:0] f; logic [15:0] g; } s_t;
  s_t s;
  assign o = s;
  if (1) begin : g
    assign s.f = {P, a};
  end
  assign s.g = 0;
endmodule
