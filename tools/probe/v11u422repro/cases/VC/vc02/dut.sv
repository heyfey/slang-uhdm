// § classChandleTdPropBareLogicVar422
// a package chandle typedef used by a package class and a $unit class
package p;
  typedef chandle ch_t;
  class P; ch_t h; endclass
endpackage
class C;
  p::ch_t h;
  static p::ch_t s;
endclass
module top;
  C c = new; p::P q = new;
endmodule
