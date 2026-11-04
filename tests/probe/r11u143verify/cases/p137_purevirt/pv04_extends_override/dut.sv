// § pureVirtProtoSpan137 (refinement R11V137_PVQUAL_OFF)
// case pv04: an abstract class with a pure virtual protected task, extended by an abstract class adding its own
virtual class A;
  pure virtual protected task run();
endclass
virtual class Bc extends A;
  pure virtual function bit ok(int x);
endclass
module top(); endmodule
