// § clsShortRealAliasElem464 (an alias of an alias of shortreal)
typedef shortreal sr_t;
typedef sr_t sr2_t;
class C;
  sr2_t d[];
endclass
module top;
  initial begin C c; c = new; end
endmodule
