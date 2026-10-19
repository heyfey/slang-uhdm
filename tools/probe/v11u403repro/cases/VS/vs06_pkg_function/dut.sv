// § stdRandomizeIsScopeRef403
package p;
  function int f();
    int x;
    return std::randomize(x) with { x > 1; };
  endfunction
endpackage
module top; endmodule
