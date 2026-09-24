// § constCallNameSpan137
// case cs08: a call with a named argument in a generate-if condition
module top(output logic [3:0] o);
  function automatic int f(input int x, input int y = 1); return x + y; endfunction
  if (f(.x(2)) == 3) begin : g
    assign o = 4'd9;
  end
endmodule
