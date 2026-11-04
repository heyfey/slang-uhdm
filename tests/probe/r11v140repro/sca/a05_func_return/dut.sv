// § sysArgUnaryWholeSpan140
module top(input logic [7:0] x, output logic [7:0] o);
  function automatic logic [7:0] f(input logic [7:0] v);
    return $unsigned(-v);
  endfunction
  assign o = f(x);
endmodule
