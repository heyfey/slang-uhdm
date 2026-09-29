// § strLitContLineSpan220
module top(output logic [63:0] o);
  function automatic logic [63:0] f(input logic [63:0] a);
    return a;
  endfunction
  assign o = f("ab\
cd");
endmodule
