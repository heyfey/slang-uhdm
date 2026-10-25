// § caCallConcatArgFormalTs432
module m(input [11:0] op, output [5:0] y);
  typedef logic [5:0] w_t;
  assign y = f({op[8:6], op[11:9]});
  function automatic w_t f(input w_t b);
    return b;
  endfunction
endmodule
