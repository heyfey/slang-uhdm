// § bitSignedElabVar412
module top(input bit signed [3:0] a, output bit signed [4:0] o);
  bit signed [3:0] x;
  assign x = a;
  assign o = x >>> 1;
endmodule
