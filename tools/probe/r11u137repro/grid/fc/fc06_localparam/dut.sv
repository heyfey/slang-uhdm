// § constCallNameSpan137
module top(output logic [7:0] o);
  function automatic int f(input int x); return x + 1; endfunction
  localparam int L = f(3);
  assign o = L;
endmodule
