// § qualShadowGenReadKeepsClone264v
package pk;
  parameter int NE = 3;
endpackage
module sub(input logic [7:0] i, output logic [7:0] o);
  import pk::*;
  localparam int NE = pk::NE;
  for (genvar k = 0; k < 2; k++) begin : g
    assign o[k] = i[NE];
  end
  assign o[7:2] = '0;
endmodule
module top(input logic [7:0] i, output logic [7:0] o);
  sub u(.i(i), .o(o));
endmodule
