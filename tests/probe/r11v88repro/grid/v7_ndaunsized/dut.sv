// v11u88 v7 -- an UNBASED UNSIZED initializer and a signed one.
interface ifc ();
  wire [31:0] w_u = '1;
  wire signed [15:0] w_s = -3;
  wire w_1b = 1'b1;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.w_u ^ {16'd0, u_if.w_s} ^ {31'd0, u_if.w_1b};
endmodule
