// § caUnsizedRhsClonePerInst193
module m (input logic [3:0] x, output logic [3:0] y);
  function automatic logic [3:0] f(logic [3:0] a, logic [3:0] b);
    return a | b;
  endfunction
  assign y[3:0] = f('0, x);
endmodule
module top (input logic [3:0] x, output logic [3:0] y1);
  m u_a (.x(x), .y(y1));
endmodule
