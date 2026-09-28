// § nestedDefChainName193
module sub ();
  module innermod (output logic [3:0] r);
    for (genvar i = 0; i < 2; i++) begin : g
      logic t;
      assign t = 1'b1;
    end
    assign r = {2'b0, g[0].t, g[1].t};
  endmodule
endmodule
module dut (output logic [3:0] o);
  sub u_s ();
  assign o = 4'd0;
endmodule
