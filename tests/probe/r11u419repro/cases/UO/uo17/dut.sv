// § implicitPortParamListedFirst419
interface ifc #(parameter A = 4, int B = 2) ();
  logic [A-1:0] x;
  localparam L = A * 2;
endinterface
module top;
  ifc u();
endmodule
