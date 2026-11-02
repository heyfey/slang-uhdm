// § clsShortRealAliasElem464 (a class-scope alias)
class C;
  typedef shortreal sr_t;
  sr_t d[];
  sr_t q[$];
endclass
module top;
  initial begin C c; c = new; end
endmodule
