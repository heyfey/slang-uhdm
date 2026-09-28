// § caTernFillArmKept193
interface ifc #(parameter bit P = 1);
  logic s;
  logic [7:0] arr [2];
  assign arr[0] = (P) ? {8{s}} : '0;
endinterface
module top;
  ifc #(.P(0)) i_a ();
endmodule
