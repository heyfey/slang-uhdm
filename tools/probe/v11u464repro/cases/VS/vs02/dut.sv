// § clsShortRealAliasElem464 (a realtime alias in a queue and a string-keyed associative)
typedef realtime rt_t;
class C;
  rt_t q[$];
  rt_t a[string];
endclass
module top;
  initial begin C c; c = new; end
endmodule
