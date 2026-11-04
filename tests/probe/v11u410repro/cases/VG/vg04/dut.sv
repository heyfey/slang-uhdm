// § genLpUntypedDefNoTs410
interface ifc #(parameter W = 4);
  logic [W-1:0] d;
  if (W > 1) begin : g
    localparam H = W / 2;
    logic [H-1:0] h;
  end
endinterface
module top;
  ifc #(8) u();
endmodule
