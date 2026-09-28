// § nestedDefChainName193
module sub ();
  module innermod (input logic c, input logic [3:0] a, output logic [3:0] y);
    logic [3:0] q;
    always_ff @(posedge c) q <= a;
    assign y = q;
  endmodule
endmodule
module dut (output logic [3:0] o);
  sub u_s ();
  assign o = 4'd0;
endmodule
