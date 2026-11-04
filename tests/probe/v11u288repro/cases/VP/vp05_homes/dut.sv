// § parenCastReadsCastSyntax288 — a parenthesized cast in a function, a task, a class method and a package function
package pp;
  function automatic int pf(logic [7:0] v); return (int'(v)) + (shortint'(v)); endfunction
endpackage
class cc;
  int k;
  function int cm(byte v); return (int'(v)) >>> 1; endfunction
endclass
module top(input logic [7:0] x, output int o, o2);
  function automatic int mf(logic [7:0] v); return (int'(v)) - 1; endfunction
  task automatic mt(output int r); r = (longint'(x)) + 1; endtask
  always_comb begin o = mf(x) + pp::pf(x); mt(o2); end
endmodule
