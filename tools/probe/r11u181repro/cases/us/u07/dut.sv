// § bareDecUnderscoreDropped181 — underscores in a function argument, a comparison and a concatenation
module top(input logic [7:0] a, output logic y, output logic [15:0] z);
  function automatic logic [7:0] f(logic [7:0] x); return x; endfunction
  assign y = a == 1_0;
  assign z = {f(8'd1_0), 8'h0_F};
endmodule
