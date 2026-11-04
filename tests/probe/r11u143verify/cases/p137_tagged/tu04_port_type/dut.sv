// § taggedUnionElabSpan137
// case tu04: a tagged packed union typedef as a sub-module port type
typedef union tagged packed {
  logic [3:0] m;
  logic [3:0] n;
} tu_t;
module sub(input tu_t x, output logic [3:0] o); assign o = x.m; endmodule
module top(input logic [4:0] i, output logic [3:0] o); sub u(.x(i), .o(o)); endmodule
