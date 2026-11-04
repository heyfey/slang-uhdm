// § oneTickUpperBNormalized425
module top(input a, output logic o, output logic p);
  always_comb begin
    o = 1'B0;
    if (a) o = 1'B1;
    p = (a === 1'BX);
  end
endmodule
