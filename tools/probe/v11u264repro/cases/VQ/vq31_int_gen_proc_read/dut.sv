// § qualShadowGenReadKeepsClone264v
package pk;
  parameter int NE = 3;
endpackage
module sub(output logic [7:0] o);
  import pk::*;
  localparam int NE = pk::NE;
  if (1) begin : g
    always_comb o = NE;
  end
endmodule
module top(output logic [7:0] o);
  sub u(.o(o));
endmodule
