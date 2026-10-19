// § deferredAssertItemDropped406
module top(input logic a, input logic b, output logic o);
  assert #0 (a) else $error("a low");
  assume final (b) $display("ok"); else $warning("b low");
  assign o = a & b;
endmodule
