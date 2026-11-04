// § implicitPortPaLastIface419
interface ifc #(parameter A = 4, int B = 2, parameter C = 1) ();
  logic [A-1:0] x;
endinterface
module top;
  ifc #(.C(3)) u[2] ();
endmodule
