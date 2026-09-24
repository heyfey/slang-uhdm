package pk; parameter int unsigned W = $clog2(4); parameter int unsigned WL = 2; parameter int S = 2; parameter U = 2; parameter logic [3:0] L = 2; endpackage
module top import pk::*; #(parameter int unsigned NUM_FB = 2, parameter int unsigned MW = 2) (input logic [NUM_FB-1:0] c, input logic s, t, input logic [2:0] q [NUM_FB], output logic [2:0] y [NUM_FB]);
  function automatic logic [2:0] f(input logic [31:0] a); return a[2:0]; endfunction
  for (genvar fb = 0; fb < NUM_FB; fb++) begin : g
    if (1) begin : h
      assign y[fb] = c[fb] ? {{W{1'b0}},s} : (q[fb] + {{W{1'b0}}, t});
    end
  end
endmodule
