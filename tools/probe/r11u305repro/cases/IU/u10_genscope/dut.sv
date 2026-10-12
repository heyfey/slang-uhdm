// § ifCaUnsizedRhsClonePerInst305
interface bif #(parameter bit P = 1)();
  logic sig;
  logic [7:0] arr [2];
  if (1) begin : g
    assign arr[1] = (P) ? {8{sig}} : '0;
  end
endinterface
module top;
  bif b0();
endmodule
