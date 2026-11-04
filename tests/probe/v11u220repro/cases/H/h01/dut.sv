// § lvIdxPathRangeTailIsRead218
typedef struct packed { logic [6:0] addr; logic [31:0] data; } req_t;
module top(input logic clk, input req_t req, output logic [3:0][31:0] o);
  logic [3:0][31:0] mem;
  always_ff @(posedge clk) mem[req.addr[1:0]] <= req.data;
  assign o = mem;
endmodule
