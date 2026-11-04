// § ndaConstRhsFreshLhs271
module sub (input logic [7:0] p, output logic o);
  wire w_in = p inside {8'd1, [8'd5:8'd6]};
  assign o = w_in;
endmodule
module dut (input logic [7:0] p, output logic o);
  sub u_s (.p(p), .o(o));
endmodule
