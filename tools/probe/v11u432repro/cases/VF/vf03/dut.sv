// § caCallConcatArgFormalTs432
module m(input [5:0] a, output [3:0] y);
  localparam [2:0] P = 3'd5;
  localparam [2:0] Q = 3'd2;
  function [3:0] f(input [5:0] b);
    f = b[3:0];
  endfunction
  assign y = f({P, Q});
endmodule
