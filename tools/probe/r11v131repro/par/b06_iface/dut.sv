// § paramFoldParenSpan131
interface ifc #(parameter W = (4 + 4)) ();
  logic [W-1:0] d;
endinterface
module top ();
  ifc u();
endmodule
