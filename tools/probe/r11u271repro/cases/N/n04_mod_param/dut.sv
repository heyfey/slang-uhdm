// § ndaConstRhsFreshLhs271
module sub #(parameter int K = 3) (output logic [31:0] o);
  localparam int L = K + 1;
  wire [31:0] w_k = K;
  wire [31:0] w_l = L;
  assign o = w_k ^ w_l;
endmodule
module dut (output logic [31:0] o);
  sub #(.K(5)) u_s (.o(o));
endmodule
