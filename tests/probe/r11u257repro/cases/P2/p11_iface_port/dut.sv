// § implicitPortTsFirstDim257 (an interface port with two packed dimensions and no type keyword)
interface ifc(input [3:0][1:0] a); logic b; assign b = a[0][0]; endinterface
module top; logic [3:0][1:0] a; ifc u(.a(a)); endmodule
