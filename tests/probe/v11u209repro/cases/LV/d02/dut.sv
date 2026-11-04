// § tfItemInitLocalAtType209: a synthesizable paren-less task-free function with initialized int local used in always_comb
module top(input logic [7:0] a, output logic [7:0] y);
  logic [7:0] g;
  function automatic logic [7:0] f;
    input logic [7:0] x;
    int k = 2;
    logic [7:0] acc = 8'd0;
    for (int i = 0; i < k; i++) acc = acc + x;
    f = acc;
  endfunction
  always_comb g = f(a);
  assign y = g;
endmodule
