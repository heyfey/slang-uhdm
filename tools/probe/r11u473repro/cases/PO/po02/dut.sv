// § modImpCopyTdChainHomeTop473
// CONTROL (no module import; the package-own face, not written): a localparam and an explicit typedef import
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::t;
  localparam t LB = 4'd3;
endpackage
module top;
endmodule
