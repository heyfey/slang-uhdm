// § selIdxCastTsNamedBySel317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module mid (ifc b, output logic o);
  assign o = b.sig[0];
endmodule
module top (input logic c, output logic o);
  ifc arr [4] (.clk(c));
  mid m (.b(arr[2'(1)]), .o(o));
endmodule
