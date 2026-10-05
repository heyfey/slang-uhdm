// § clsTdAssocIdxKwLoc251 (a class associative typedef indexed by the keyword longint)
package p;
class c #(type T = int);
  typedef T tab_t [longint];
  tab_t m;
endclass
endpackage
module top; p::c#(int) h; endmodule
