// § dottedCallHpSpansInvocation294
// a built-in queue method through an interface instance
interface ifc; int q[$]; string s; endinterface
module top(output int o, output string so);
  ifc i0 ();
  always_comb o = i0.q.size();
  initial so = i0.s.toupper();
endmodule
