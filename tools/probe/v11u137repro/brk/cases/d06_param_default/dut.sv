// § constCallNameSpan137
module sub #(parameter int W = 4)(output logic [W-1:0] o);
  assign o = '0;
endmodule
module top(output logic [3:0] o);
  function automatic int f(input int x); return x + 1; endfunction
  sub #(.W(f(3))) u(.o(o));
endmodule
