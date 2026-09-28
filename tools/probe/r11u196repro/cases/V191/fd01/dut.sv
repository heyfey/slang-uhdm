// § formalDefaultNamedThroughFormal191: a package function whose default adds a package parameter to another formal, and a concatenation default
package p;
  parameter int K = 3;
  function automatic int f(int a, int b = a + K, logic [7:0] c = {a[3:0], b[3:0]});
    return a + b + c;
  endfunction
endpackage
module top(output int o);
  assign o = p::f(1);
endmodule
