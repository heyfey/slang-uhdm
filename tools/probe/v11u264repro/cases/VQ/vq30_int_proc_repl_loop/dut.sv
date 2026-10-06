// § pkgQualRefShadowOwnTs264
package pk;
  parameter int NE = 3;
endpackage
module sub(output logic [7:0] o);
  import pk::*;
  localparam int NE = pk::NE;
  always_comb begin
    o = '0;
    for (int i = 0; i < NE; i++) o[i] = 1'b1;
    o[7:5] = {NE{1'b1}};
  end
endmodule
module top(output logic [7:0] o);
  sub u(.o(o));
endmodule
