// § unsignedScalarVecTsAtKeyword137
module top(output logic o);
  if (1) begin : g
    bit unsigned x;
    assign x = 1'b1;
  end
  assign o = g.x;
endmodule
