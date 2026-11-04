// § clsTdAssocIdxKwLoc251 (a class associative typedef indexed by the keyword shortint)
package p;
class c #(type T = int);
  typedef T tab_t [shortint];
  tab_t m;
endclass
endpackage
module top; p::c#(int) h; endmodule
