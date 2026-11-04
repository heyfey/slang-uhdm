// § clsTdAssocIdxKwLoc251 (the keyword index written with surrounding spaces and a comment)
package p;
class c #(type T = int);
  typedef T tab_t [ /*k*/ string  ];
  tab_t m;
endclass
endpackage
module top; p::c#(int) h; endmodule
