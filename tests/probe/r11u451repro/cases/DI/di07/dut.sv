// § diamondImportParamAssignsPerPath451
package a;
  parameter int PA = 1;
  localparam int LA = PA + 1;
endpackage
package b;
  import a::*;
  parameter int PB = 2;
endpackage
package c;
  import a::*;
  import b::*;
endpackage
package d;
  import c::*;
endpackage
module top;
  import d::*;
  logic w;
endmodule
