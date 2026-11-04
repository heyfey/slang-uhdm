module top(output logic o);
  always_comb begin
    logic idx [7:0];
    idx[0] = 1'b1;
    o = idx[0];
  end
endmodule
