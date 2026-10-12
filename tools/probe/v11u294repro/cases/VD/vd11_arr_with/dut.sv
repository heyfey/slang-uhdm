// § dottedCallHpSpansInvocation294
// an array method with a with clause through an interface
interface ifc; int a [4]; endinterface
module top(output int o);
  ifc i0 ();
  initial o = i0.a.sum() with (item * 2);
endmodule
