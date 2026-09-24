// § pureVirtProtoSpan137 (refinement R11V137_PVQUAL_OFF)
// case pv03: pure virtual local task and pure virtual protected function returning a package typedef
package tq; typedef logic [3:0] n_t; endpackage
virtual class K;
  pure virtual local task lt(int a);
  pure virtual protected function tq::n_t pf();
endclass
module top(); endmodule
