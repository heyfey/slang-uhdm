// § ovrMultiDimConstUnparented131
// case o03: an overridden 2-D packed parameter of an interface
interface ifc #(parameter logic [1:0][3:0] M = '0);
  logic [7:0] d;
  assign d = M;
endinterface
module top(output logic [7:0] o);
  ifc #(.M(8'hA5)) u();
  assign o = u.d;
endmodule
