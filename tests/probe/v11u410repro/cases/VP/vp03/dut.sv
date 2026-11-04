// § parenCastNameUnsupTs410
module top #(parameter W = 4) (input logic [7:0] x, output logic [7:0] y);
  function automatic logic [7:0] f(input logic [7:0] a);
    return (W)'(a);
  endfunction
  assign y = f(x);
endmodule
