// § caCallConcatArgFormalTs432
module m(input [11:0] op, output logic [3:0] y);
  always_comb y = f({op[8:6], op[11:9]});
  function [3:0] f(input [5:0] b);
    f = b[3:0];
  endfunction
endmodule
