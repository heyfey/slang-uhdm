// § pureVirtProtoSpan137 (refinement R11V137_PVQUAL_OFF)
// case pv06: a pure virtual protected function in a parameterized class
virtual class Pc #(int N = 2);
  pure virtual protected function logic [N-1:0] m();
endclass
module top(); endmodule
