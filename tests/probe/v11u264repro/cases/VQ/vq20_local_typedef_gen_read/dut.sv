// § qualShadowGenReadKeepsClone264v
package pk;
  parameter logic [7:0] NE = 8'd12;
endpackage
module sub(output logic [7:0] o);
  import pk::*;
  typedef logic [7:0] lb_t;
  localparam lb_t NE = pk::NE;
  if (1) begin : g
    assign o = NE;
  end
endmodule
module top(output logic [7:0] o);
  sub u(.o(o));
endmodule
