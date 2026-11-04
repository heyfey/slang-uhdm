// § ndaConstRhsFreshLhs271
module sub #(parameter int W = 8) (output logic [31:0] o);
  wire [31:0] w_c = $clog2(W);
  wire [31:0] w_b = $bits(o);
  assign o = w_c ^ w_b;
endmodule
module dut (output logic [31:0] o);
  sub #(.W(16)) u_s (.o(o));
endmodule
