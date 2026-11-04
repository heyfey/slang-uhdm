// § formalDefaultNamedThroughFormal191: a static method of a module-local class and a generate-block function whose defaults name a formal, a module parameter and a package constant
package pk; parameter int K = 2; endpackage
module top #(parameter int W = 3) (output int o);
  class c;
    static function int sf(int m, int n = m + pk::K);
      return m + n;
    endfunction
  endclass
  if (W > 1) begin : g
    function automatic int gf(int a, int b = a + W);
      return a + b;
    endfunction
    assign o = gf(1, 2);
  end
endmodule
