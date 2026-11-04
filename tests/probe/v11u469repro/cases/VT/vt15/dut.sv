// § importCopyTsInstByRole469
// the importer declares its own typedef t and explicitly imports a parameter typed a::t
package a;
  typedef logic [3:0] t;
  parameter t PA = 4'd3;
endpackage
package b;
  typedef logic [7:0] t;
  import a::PA;
  parameter t PB = 8'd9;
endpackage
module top;
  logic w;
endmodule
