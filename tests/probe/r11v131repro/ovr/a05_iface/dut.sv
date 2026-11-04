// § ovrMultiDimConstUnparented131
interface ifc #(parameter logic [1:0][3:0] P = '0) ();
endinterface
module top ();
  ifc #(.P(8'h3)) u();
endmodule
