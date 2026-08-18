// v98_c15 — MANY racers, alphabetically BEFORE and AFTER, mixed case, digits,
// three unrelated packages.  Deliberately NOT a self-confirming a/b/c grid.
package Zulu15v;
  class Kilo15v;  typedef bit [1:0] mx15_t; endclass
  class alpha15v; typedef bit [2:0] mx15_t; endclass
endpackage
package delta15v;
  class Whisky15v; typedef bit [3:0] mx15_t; endclass
  class echo15v;   typedef bit [4:0] mx15_t; endclass
endpackage
package mike15v;
  class Base15v;  typedef int mx15_t; function void own(mx15_t x); endfunction endclass
  class Der15v extends Base15v; function void hot(mx15_t x); endfunction endclass
  class zzz15v;   typedef bit [5:0] mx15_t; endclass
endpackage
module top15v;
  mike15v::Der15v z;
  Zulu15v::Kilo15v k;
  delta15v::Whisky15v w;
  initial begin z = new(); k = new(); w = new(); end
endmodule
