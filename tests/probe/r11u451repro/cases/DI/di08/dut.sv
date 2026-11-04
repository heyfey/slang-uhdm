// § diamondImportListsPerPath451
package a;
  int va;
  logic [1:0] la;
endpackage
package b;
  import a::*;
endpackage
package c;
  import a::*;
endpackage
package d;
  import b::*;
  import c::*;
endpackage
package e;
  import d::*;
  int ve;
endpackage
module top;
  import e::*;
  initial ve = 2;
endmodule
