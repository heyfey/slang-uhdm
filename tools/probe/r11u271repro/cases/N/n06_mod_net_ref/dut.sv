// § ndaConstRhsFreshLhs271
module sub (input logic [31:0] a, output logic [31:0] o);
  wire [31:0] w_a = a;
  wire [31:0] w_b = w_a;
  assign o = w_b;
endmodule
module dut (input logic [31:0] a, output logic [31:0] o);
  sub u_s (.a(a), .o(o));
endmodule
