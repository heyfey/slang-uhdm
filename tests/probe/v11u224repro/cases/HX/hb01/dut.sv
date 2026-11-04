// § hpLvNewClassFirstElemSpan224
module top;
  class s; endclass
  class r; s parent; endclass
  for (genvar g = 0; g < 2; g++) begin : gb
    r rw;
    initial begin
      rw = new;
      rw.parent = new;
    end
  end
endmodule
