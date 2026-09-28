// § nestedDefChainName193
module sub ();
  module innermod (a, y);
    input [3:0] a;
    output [3:0] y;
    wire [3:0] n;
    assign n = ~a;
    assign y = n;
  endmodule
endmodule
module dut (output logic [3:0] o);
  sub u_s ();
  assign o = 4'd0;
endmodule
