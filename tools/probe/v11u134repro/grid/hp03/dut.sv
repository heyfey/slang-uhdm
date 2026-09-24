// § tsHierPathElemNoName134
typedef struct packed { int unsigned W; int unsigned D; } cfg_t;
module top #(parameter cfg_t C = '{W: 4, D: 2}) (input logic [3:0] i, output logic [3:0] o);
  function automatic logic [C.W-1:0] f(input logic [C.W-1:0] a);
    return ~a;
  endfunction
  logic [C.W-1:0] r;
  assign r = f(i);
  assign o = r;
endmodule
