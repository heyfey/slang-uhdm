// § unaryOperandParamOwnerName145
typedef struct packed { logic [7:0] f; } s_t;
module dut #(parameter logic [7:0] M = 8'h0F) ();
  logic [7:0] a;
  s_t [1:0] o;
  if (1) begin : g
    localparam int c = 1;
    assign o[c].f = a & ~M;
  end
endmodule
