// § tsHierPathElemNoName134
typedef struct packed { int unsigned W; int unsigned D; } cfg_t;
module top #(parameter cfg_t C = '{W: 4, D: 2}) (input logic [3:0] i, output logic [3:0] o);
  logic [C.W-1:0] mem [C.D];
  for (genvar g = 0; g < C.D; g++) begin : gb
    logic [C.W-1:0] r;
    assign r = i;
  end
  assign mem[0] = i;
  assign o = mem[0] ^ gb[0].r;
endmodule
