// v11u88 v3 -- LAW A WIDTH: a SIZED 64-bit literal into a narrower net.  The
// builder resizes ANY constant whose VpiSize is 64 to the net's width.
interface ifc ();
  wire [31:0] w_64 = 64'd5;
  wire [63:0] w_w64 = 64'd6;
  wire [31:0] w_bare = 7;
endinterface

module dut (output logic [63:0] o);
  ifc u_if ();
  assign o = {32'd0, u_if.w_64} ^ u_if.w_w64 ^ {32'd0, u_if.w_bare};
endmodule
