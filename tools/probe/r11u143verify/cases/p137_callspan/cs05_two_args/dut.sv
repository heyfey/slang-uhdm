// § constCallNameSpan137
// case cs05: a two-argument call in a generate-if condition
module top(output logic [3:0] o);
  function automatic int mx(input int a, input int b); return a > b ? a : b; endfunction
  if (mx(2, 3) > 2) begin : g
    assign o = 4'd3;
  end else begin : h
    assign o = 4'd4;
  end
endmodule
