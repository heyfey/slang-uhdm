// § bitSignedElabVar412
interface ifc;
  bit signed [3:0] x;
endinterface
module top(output logic [7:0] o);
  ifc i();
  for (genvar g = 0; g < 2; g++) begin : gb
    bit signed [3:0] y;
    assign y = -g;
  end
  assign o = gb[1].y;
endmodule
