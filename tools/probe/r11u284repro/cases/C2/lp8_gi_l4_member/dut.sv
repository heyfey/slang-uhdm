// § genCaCatMemberInst284
module dut(input logic a, output logic [31:0] o);
  localparam logic [7:0] P = 8'd3;
  typedef struct packed { logic [15:0] f; logic [15:0] g; } s_t;
  s_t s;
  assign o = s;
  if (1) begin : g
    assign s.f = {P, 1'b0};
  end
  assign s.g = 0;
endmodule
