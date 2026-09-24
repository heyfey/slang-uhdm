// § streamOperandBraceSpan140
module top(input logic [7:0] a, output logic [7:0] o);
  function automatic logic [7:0] f(input logic [7:0] v); return v; endfunction
  assign o = f({ << 4 { a } });
endmodule
