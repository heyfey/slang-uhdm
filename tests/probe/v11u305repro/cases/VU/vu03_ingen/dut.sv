// § ifCaUnsizedRhsClonePerInst305
interface bif();
  logic sig;
  logic [7:0] arr[2];
  assign arr[1] = {8{sig}} & '1;
endinterface
module top;
  for (genvar i = 0; i < 2; i++) begin : g
    bif b();
  end
endmodule
