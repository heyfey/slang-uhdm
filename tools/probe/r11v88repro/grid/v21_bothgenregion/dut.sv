// v11u88 v21 -- LAW B inside an explicit GENERATE REGION of an interface, the
// path r11u83's index walk splices in separately (genRegion83).
interface ifc ();
  logic [31:0] a;
  assign a = 32'd1;
  generate
    logic [31:0] b;
    assign (weak1, strong0) #2 b = 32'd2;
    logic [31:0] c;
    assign c = 32'd3;
  endgenerate
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.a ^ u_if.c;
endmodule
