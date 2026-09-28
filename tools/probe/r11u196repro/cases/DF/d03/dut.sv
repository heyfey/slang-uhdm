// § evalFuncOmittedDefaultKeepsCall196: a package function called from a module with the defaulted argument omitted, in a generate block and at module scope
package p;
  function automatic int f(int a, int b = 5); return a + b; endfunction
endpackage
module top(output int o1, output int o2);
  assign o1 = p::f(1);
  if (1) begin : g
    assign o2 = p::f(2);
  end
endmodule
