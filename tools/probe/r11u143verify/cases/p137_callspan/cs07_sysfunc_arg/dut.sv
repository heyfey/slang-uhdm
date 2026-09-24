// § constCallNameSpan137
// case cs07: a call whose argument is a system function, in a generate-if condition
module top(output logic [3:0] o);
  function automatic int f(input int x); return x; endfunction
  if (f($bits(o)) > 1) begin : g
    assign o = 4'd1;
  end
endmodule
