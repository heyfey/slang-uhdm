// § constCallNameSpan137
package q;
  function automatic int w(input int x); return x + 1; endfunction
endpackage
module top(input logic [q::w(3)-1:0] a, output logic [q::w(3)-1:0] b);
  assign b = a;
endmodule
