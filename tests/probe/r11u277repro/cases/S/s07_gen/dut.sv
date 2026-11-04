// § strPortNetTsFromPortDecl277
module sub #(parameter W = 8) (o);
  output [W-1:0] o;
  wire (strong1, weak0) [W-1:0] o = '1;
  generate if (W > 4) begin : g
    wire (strong1, weak0) [3:0] w = 4'd1;
  end endgenerate
endmodule
module dut (output logic [7:0] o, output logic [15:0] o2);
  sub u_s (.o(o));
  sub #(16) u_t (.o(o2));
endmodule
