// § qualShadowGenReadKeepsClone264v
package pk;
  typedef logic [7:0] byte_t;
  parameter byte_t NE = 8'd12;
endpackage
module sub(output logic [7:0] o);
  import pk::*;
  localparam byte_t NE = pk::NE;
  if (1) begin : g
    assign o = NE;
  end
endmodule
module top(output logic [7:0] o);
  sub u(.o(o));
endmodule
