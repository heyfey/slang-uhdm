// § pkgQualRefShadowOwnTs264
package pk;
  typedef int count_t;
  parameter count_t NE = 12;
endpackage
module sub(output logic [7:0] o);
  import pk::*;
  localparam count_t NE = pk::NE;
  assign o = '0;
endmodule
module top(output logic [7:0] o);
  sub u(.o(o));
endmodule
