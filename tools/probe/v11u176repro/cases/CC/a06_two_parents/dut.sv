// § castRhsClonePerInst176
module leaf #(parameter Y = 1) ();
  assign a = 8'(Y);
endmodule
module mid1; leaf #(.Y(2)) l (); endmodule
module mid2; leaf #(.Y(3)) l (); endmodule
module top; mid1 m1 (); mid2 m2 (); endmodule
