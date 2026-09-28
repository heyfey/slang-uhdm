// § nestedDefChainName193
module sub ();
  module innermod #(parameter int W = 4) (output logic [W-1:0] r);
    localparam int H = W / 2;
    logic [H-1:0] h;
    assign h = '1;
    assign r = {h, h};
  endmodule
  wire [3:0] q = 4'd1;
endmodule
module dut (output logic [3:0] o);
  sub u_s ();
  assign o = 4'd0;
endmodule
