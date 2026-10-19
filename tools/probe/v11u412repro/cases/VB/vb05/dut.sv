// § bitSignedElabVar412
package pk;
  bit signed [3:0] pv;
endpackage
module top(output logic [7:0] o);
  bit signed [7:0] z = -1;
  bit signed s1;
  assign s1 = 1'b1;
  assign o = z + s1;
endmodule
