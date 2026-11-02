// § clsShortRealAliasElem464 (control: a shortreal keyword element and a real alias)
typedef real r_t;
class C;
  shortreal d[];
  r_t q[$];
endclass
module top;
  initial begin C c; c = new; end
endmodule
