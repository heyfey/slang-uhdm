// § caCallConcatArgFormalTs432
module m(input [31:0] op, output [5:0] y);
  assign y = f({op[15:0], op[31:16]});
  function automatic [5:0] f(input int b);
    return b[5:0];
  endfunction
endmodule
