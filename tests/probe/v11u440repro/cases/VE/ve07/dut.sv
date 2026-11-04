// § errTypePortSyntaxRange440
interface ifc #(parameter x = "inv") ();
  logic [x-1:0] v;
endinterface
module top; endmodule
