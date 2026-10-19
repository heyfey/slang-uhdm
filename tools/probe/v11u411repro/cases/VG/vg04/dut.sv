// § genvarCastTgtUnsupTs411
interface ifc (input logic [7:0] x);
  logic [7:0] y [2];
  for (genvar i = 1; i < 3; i++) begin : g
    assign y[i-1] = (i)'(x);
  end
endinterface
module top (input logic [7:0] x);
  ifc u (x);
endmodule
