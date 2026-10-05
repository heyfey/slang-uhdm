// § clsTdAssocIdxKwLoc251 (control: a packed bit-vector index is not in the keyword list)
package p;
class c #(type T = int);
  typedef T tab_t [bit [3:0]];
  tab_t m;
endclass
endpackage
module top; p::c#(int) h; endmodule
