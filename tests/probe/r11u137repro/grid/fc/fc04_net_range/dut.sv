// § constCallNameSpan137
module top();
  function automatic int f(input int x); return x + 1; endfunction
  logic [f(3)-1:0] v;
  assign v = '0;
endmodule
