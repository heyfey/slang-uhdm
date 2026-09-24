// § constCallNameSpan137
// case cs03: a generate-if condition adding two calls
module top(output logic [3:0] o);
  function automatic int f(input int x); return x; endfunction
  if ((f(1) + f(2)) > 2) begin : g
    assign o = 4'd5;
  end else begin : h
    assign o = 4'd6;
  end
endmodule
