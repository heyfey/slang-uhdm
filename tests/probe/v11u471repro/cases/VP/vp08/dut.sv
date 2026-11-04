// § procAsgRhsPkgFoldTs471
// explicitly imported parameter in a module that is a submodule of two different parents
package a;
  parameter logic [3:0] PA = 4'd10;
endpackage
module sub(output logic [3:0] o);
  import a::PA;
  always_comb o = PA;
endmodule
module p1(output logic [3:0] o); sub s(.o(o)); endmodule
module top(output logic [3:0] y, output logic [3:0] z);
  p1 x1(.o(y));
  sub x2(.o(z));
endmodule
