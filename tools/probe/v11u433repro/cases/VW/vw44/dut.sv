// § genCaBitsSelectKeeps433v
module top #(parameter W = 2) ();
  logic [7:0] x;
  logic [3:0] pk [2];
  wire [7:0] y1, y2, y3;
  if (W <= 4) begin: g
    assign y1 = $bits(x[1]) + 1;
    assign y2 = $size(x[3:0]);
    assign y3 = $bits(pk[0]) * 2;
  end
endmodule
