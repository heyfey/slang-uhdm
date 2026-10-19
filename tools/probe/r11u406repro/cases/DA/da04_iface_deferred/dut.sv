// § deferredAssertItemDropped406
interface I;
  logic a;
  assert #0 (a);
endinterface
module top;
  I i();
endmodule
