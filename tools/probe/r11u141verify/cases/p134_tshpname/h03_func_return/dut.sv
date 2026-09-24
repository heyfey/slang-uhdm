// § tsHierPathElemNoName134
// case h03: a function local variable ranged by a struct-parameter member, parameter overridden
typedef struct packed { logic [3:0] W; logic [3:0] D; } cfg_t;
module sub #(parameter cfg_t Cfg = '{W: 4'd3, D: 4'd1}) (input logic [7:0] i, output logic [7:0] o);
  function automatic logic [7:0] f(input logic [7:0] v);
    logic [Cfg.W-1:0] t;
    t = v;
    return t;
  endfunction
  assign o = f(i);
endmodule
module top(input logic [7:0] i, output logic [7:0] o);
  sub #(.Cfg('{W: 4'd6, D: 4'd2})) u(.i(i), .o(o));
endmodule
