// § namedSlotFillerRootFile207 (module, generate, continuous assignment, interface function; one call from a macro in an included header)
`include "mac.svh"
interface ifc ();
  function automatic int fi(int a, int b = 3, int c = 4);
    return a + b + c;
  endfunction
  int v;
  assign v = fi(.c(1), .a(2));
endinterface
module top (input int x, output int o [2], output int q);
  function automatic int fm(int a, int b = 1, int c = 2);
    return a * b + c;
  endfunction
  ifc u ();
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = fm(.a(x), .c(i));
  end
  always_comb q = `CALLM(x);
endmodule
