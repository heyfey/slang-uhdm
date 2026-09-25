// § modArrayBoundRefArrayPath146
interface ifc; logic d; endinterface
module top #(parameter N = 2, parameter L = 1) (input [N-1:0] a);
  ifc m[N-1:L-1] ();
endmodule
