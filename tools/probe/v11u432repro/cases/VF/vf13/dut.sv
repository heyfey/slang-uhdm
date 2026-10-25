// § caCallConcatArgFormalTs432
module m(input [5:0] a, output [3:0] y);
  function [3:0] f(input [5:0] b = 6'd0, input [5:0] c = 6'd1);
    f = b[3:0] ^ c[3:0];
  endfunction
  assign y = f(, {a[2:0], a[5:3]});
endmodule
