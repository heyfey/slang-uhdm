// v11u88 v17 -- a PACKED ARRAY net and an UNPACKED array net with an
// assignment-pattern initializer in an interface.
interface ifc ();
  wire [1:0][7:0] w_pk = 16'h1234;
  wire [31:0] w_pl = 32'd11;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = {16'd0, u_if.w_pk} ^ u_if.w_pl;
endmodule
