// § vlogAggMemberKwSpan237
// a struct-typed module port and a function formal
module top(input logic [3:0] i, output [3:0] o);
  typedef struct packed { logic [1:0] a; bit [1:0] b; } s_t;
  function [3:0] f(input s_t v);
    f = v;
  endfunction
  assign o = f(i);
endmodule
