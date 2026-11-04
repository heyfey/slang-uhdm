// § caCallConcatArgFormalTs432
module m(input [11:0] op, output [5:0] y);
  assign y = f({op[8:6], op[11:9]});
  function automatic [5:0] f(input reg [5:0] b);
    return b;
  endfunction
endmodule
