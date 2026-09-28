// § modPkgGenericSpecNamedBare202
package p;
  class C #(parameter int W = 4);
    logic [W-1:0] v;
  endclass
endpackage
program prg;
  p::C #(8) h = new;
  initial $display(h.v);
endprogram
module top;
  if (1) begin : g
    p::C #(8) gh;
  end
  for (genvar i = 0; i < 2; i++) begin : f
    p::C #(i + 1) fh;
  end
  prg pp();
endmodule
