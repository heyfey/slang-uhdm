// § genCaCatMemberInst284
module dut(input logic a, output logic [31:0] o);
  typedef struct packed { logic [15:0] hi; logic [15:0] lo; } s_t;
  localparam logic [63:0] P = 1;
  s_t w;
  assign w.hi = 0;
  assign o = w;
  if (1) begin : g
    assign w.lo = {P, a};
  end
endmodule
