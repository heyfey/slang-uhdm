// § firstListerNamesClassTd463 (non-parameterized class typedef in two packages, later package first)
package u;
  class item; endclass
  class S #(type REQ = item);
    REQ r;
  endclass
  class C; int k; endclass
endpackage
package b;
  import u::*;
  typedef C b_ct;
endpackage
package a;
  import u::*;
  typedef C a_ct;
endpackage
module top;
endmodule
