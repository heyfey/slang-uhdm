// § constCallNameSpan137
module top #(parameter int P = 3)(input logic [f(P)-1:0] a, output logic [f(P)-1:0] b);
  function automatic int f(input int x); return x + 1; endfunction
  assign b = a;
endmodule
