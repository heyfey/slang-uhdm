// § paramFoldParenSpan131
interface ifc #(parameter int W = (4 + 4)) ();
  logic [W-1:0] d;
endinterface
module top ();
  ifc #(.W(16)) u();
endmodule
