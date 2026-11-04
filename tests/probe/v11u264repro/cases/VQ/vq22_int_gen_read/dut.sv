// § qualShadowGenReadKeepsClone264v
package pk;
  parameter int NE = 12;
endpackage
module sub(output logic [31:0] o);
  import pk::*;
  localparam int NE = pk::NE;
  if (1) begin : g
    assign o = NE;
  end
endmodule
module top(output logic [31:0] o);
  sub u(.o(o));
endmodule
