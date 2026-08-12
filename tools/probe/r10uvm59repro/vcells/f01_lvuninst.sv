// VERIFIER CELL f01 - the LVALUE over-fire in the SECOND silent population.
module top59f01;
  int i;
  if (0) begin : gblk
    initial begin
      nosuchpkg59::sig = 1;
    end
  end
  initial begin
    i = 1;
  end
endmodule
