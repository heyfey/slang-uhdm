// § elabParamRefSignedTsUnlocated264
interface ifc #(parameter int W = 4);
  localparam int A = W;
  localparam int B = A;
  logic [B-1:0] d;
endinterface
module cons (ifc p, output logic [7:0] o);
  localparam int L = 3;
  localparam int L2 = L;
  assign o = p.d + L2;
endmodule
module top(output logic [7:0] o, output logic [7:0] o2);
  ifc i1();
  ifc #(.W(6)) i2();
  cons c1(.p(i1), .o(o));
  cons c2(.p(i2), .o(o2));
endmodule
