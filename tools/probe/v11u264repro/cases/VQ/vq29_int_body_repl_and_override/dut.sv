// § pkgQualRefShadowOwnTs264
package pk;
  parameter int NE = 3;
endpackage
module child #(parameter int K = 1) (output logic [7:0] o);
  assign o = K;
endmodule
module sub(output logic [7:0] o, output logic [7:0] p);
  import pk::*;
  localparam int NE = pk::NE;
  assign o = {NE{1'b1}};
  child #(.K(NE)) c(.o(p));
endmodule
module top(output logic [7:0] o, output logic [7:0] p);
  sub u(.o(o), .p(p));
endmodule
