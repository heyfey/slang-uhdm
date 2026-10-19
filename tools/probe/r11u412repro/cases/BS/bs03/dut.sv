// § bitSignedElabVar412
module top();
  if (1) begin : g
    bit signed gv;
    bit signed [7:0] gw;
  end
  bit signed m = 1'b1;
  var bit signed n;
  static bit signed o;
endmodule
