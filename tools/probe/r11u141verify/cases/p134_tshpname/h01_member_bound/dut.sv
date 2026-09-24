// § tsHierPathElemNoName134
// case h01: a local variable ranged by a struct-parameter member
module sub #(parameter struct packed { logic [3:0] W; logic [3:0] D; } Cfg = '{W: 4'd5, D: 4'd2}) (output logic [7:0] o);
  logic [Cfg.W-1:0] x;
  assign x = '1;
  assign o = x;
endmodule
module top(output logic [7:0] o);
  sub u(.o(o));
endmodule
