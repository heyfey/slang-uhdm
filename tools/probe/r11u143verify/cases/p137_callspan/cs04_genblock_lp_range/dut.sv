// § constCallNameSpan137
// case cs04: a call in the range of a net declared in a generate block
module top(output logic [3:0] o);
  function automatic int f(input int x); return x + 3; endfunction
  if (1) begin : g
    logic [f(1)-1:0] w;
    assign w = 4'hA;
    assign o = w;
  end
endmodule
