// v11u88 v6 -- ONE net declaration, THREE declarators, mixed init.
interface ifc ();
  wire [31:0] a = 32'd1, b = 32'd2, c;
  assign c = 32'd3;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.a ^ u_if.b ^ u_if.c;
endmodule
