// § tsHierPathElemNoName134
typedef struct packed { int unsigned W; } cfg_t;
module sub #(parameter cfg_t C = '{W: 4}) (input logic [C.W-1:0] i, output logic [C.W-1:0] o);
  assign o = i;
endmodule
module top(input logic [5:0] i, output logic [5:0] o);
  sub #(.C('{W: 6})) u(.i(i), .o(o));
endmodule
