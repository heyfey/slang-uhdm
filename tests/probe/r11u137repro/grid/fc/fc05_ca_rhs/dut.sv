// § constCallNameSpan137
module top(output logic [7:0] o);
  function automatic int f(input int x); return x + 1; endfunction
  assign o = f(3);
endmodule
