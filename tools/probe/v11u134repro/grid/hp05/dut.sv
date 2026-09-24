// § tsHierPathElemNoName134
typedef struct packed { int unsigned W; int unsigned D; } cfg_t;
module top #(parameter cfg_t C = '{W: 4, D: 2}) (input logic [3:0] i, output logic [3:0] o);
  logic [3:0] mem [C.D];
  logic [C.W-1:0] r [C.D-1:0];
  assign mem[0] = i;
  assign r[0] = mem[0];
  assign o = r[0];
endmodule
