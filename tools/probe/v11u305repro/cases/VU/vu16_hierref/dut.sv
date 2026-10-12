// § ifCaUnsizedRhsClonePerInst305
interface bif();
  logic sig;
  logic [7:0] arr[2];
  if (1) begin : g
    logic s;
  end
  assign arr[0] = {8{g.s}} | '0;
endinterface
module top;
  bif b0();
  bif b1();
endmodule
