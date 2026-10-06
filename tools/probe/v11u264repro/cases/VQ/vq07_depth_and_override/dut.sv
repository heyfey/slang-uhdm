// § pkgQualRefShadowOwnTs264
package pk;
  parameter int NE = 12;
endpackage
module leaf(output logic [7:0] o);
  import pk::*;
  localparam int NE = pk::NE;
  assign o = NE;
endmodule
module mid(output logic [7:0] o, output logic [7:0] p);
  leaf l1(.o(o));
  leaf l2(.o(p));
endmodule
module top(output logic [7:0] o, output logic [7:0] p);
  mid m(.o(o), .p(p));
endmodule
