// § ndaSizeFoldReach219 § sizeReachFollowsWalker219v — $size(x, d) where d is a localparam and a genvar expression inside a generate loop, and a nested interface-scope array
module top(output logic [7:0] o [2]);
  logic [3:0] m [2][6];
  localparam int D = 2;
  wire [7:0] wl = $size(m, D);
  for (genvar i = 0; i < 2; i++) begin : g
    wire [7:0] wg = $size(m, i + 1);
    assign o[i] = wg + wl;
  end
endmodule
