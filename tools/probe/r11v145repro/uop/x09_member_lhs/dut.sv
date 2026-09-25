// § unaryOperandParamOwnerName145
typedef struct packed { logic [3:0] f; logic [3:0] h; } s_t;
module dut #(parameter logic [3:0] M = 4'h3) (input logic [3:0] a, output s_t s);
  if (1) begin : g
    assign s.f = a & ~M;
    assign s.h[3:0] = a & ~M;
  end
endmodule
