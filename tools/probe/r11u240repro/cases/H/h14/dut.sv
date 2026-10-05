// § hoistPoolSourceOrder240: named-argument calls (linked and unlinked) and a class specialization in a bound
package hp;
  class pc #(parameter int W = 3);
    localparam int WW = W + 1;
  endclass
  function automatic int f2(int a, int b = 2);
    return a + b;
  endfunction
  class zb;
    int g;
    logic [pc#(5)::WW-1:0] bv;
    extern function int get();
  endclass
  function int zb::get();
    return f2(.a(g), .b(g)) + f2(.a(g));
  endfunction
  class aa;
    int g;
    extern function int get();
  endclass
  function int aa::get();
    return f2(g);
  endfunction
endpackage
module top;
  import hp::*;
  initial $display("x");
endmodule
