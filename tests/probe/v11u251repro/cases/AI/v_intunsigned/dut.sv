// § clsTdAssocIdxKwLoc251 (a class associative typedef indexed by int unsigned)
package p;
class c #(type T = int);
  typedef T tab_t [int unsigned];
  tab_t m;
endclass
endpackage
module top; p::c#(int) h; endmodule
