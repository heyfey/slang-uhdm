// § nestedDefChainName193
module sub ();
  module mid (output logic [3:0] m);
    module inner (output logic [3:0] q);
      assign q = 4'd3;
    endmodule
    assign m = 4'd2;
  endmodule
  wire [3:0] w = 4'd1;
endmodule
module dut (output logic [3:0] o);
  sub u_s ();
  assign o = 4'd0;
endmodule
