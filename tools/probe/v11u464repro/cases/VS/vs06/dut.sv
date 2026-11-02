// § clsShortRealAliasElem464 (a realtime alias dynamic array property)
typedef realtime rt_t;
class C;
  rt_t d[];
endclass
module top;
  initial begin C c; c = new; end
endmodule
