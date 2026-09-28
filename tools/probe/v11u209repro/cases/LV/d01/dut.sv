// § tfItemInitLocalAtType209: a synthesizable function with a body input and an initialized local
module top(input logic [3:0] a, output logic [3:0] y);
  function automatic logic [3:0] f;
    input logic [3:0] x;
    logic [3:0] t = 4'd1;
    f = x + t;
  endfunction
  assign y = f(a);
endmodule
