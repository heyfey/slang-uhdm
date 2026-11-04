// § bitSelParenIdxSpan181 — a parenthesized index in a package function and a class method
package p;
  function automatic logic f(logic [7:0] v, int i); return v[(i+1)]; endfunction
endpackage
module top(input logic [7:0] din, input int i, output logic y, output logic z);
  class C; logic [7:0] q; function logic g(int i); return q[(i*2)]; endfunction endclass
  assign y = p::f(din, i);
  initial begin C c = new; z = c.g(i); end
endmodule
