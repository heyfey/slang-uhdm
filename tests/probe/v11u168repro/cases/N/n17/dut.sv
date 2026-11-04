// § ppOutputLine166
`define WRAP(e) (e)
module top(input logic [3:0] a, output logic [3:0] y);
  function automatic logic [3:0] f(logic [3:0] p, logic [3:0] q); return p ^ q; endfunction
  assign y = `WRAP(f(a,
                     4'd3));
endmodule
