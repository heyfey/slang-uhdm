// § unsignedScalarVecTsAtKeyword137
// case us03: scalar reg unsigned in a generate block and logic unsigned in an interface with a modport
interface sif;
  logic unsigned s;
  modport m(input s);
endinterface
module top(input logic i, output logic o);
  sif bi();
  assign bi.s = i;
  for (genvar g = 0; g < 1; g++) begin : gg
    reg unsigned r;
    assign o = bi.s;
  end
endmodule
