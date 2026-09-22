// r11u88 z6 -- LAW B x the GEN-SCOPE home of an interface and of a module.
interface ifc ();
  generate
    if (1) begin : gl
      logic [31:0] c_both;
      assign (pull1, supply0) #3 c_both = 32'd10;
    end
  endgenerate
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  generate
    if (1) begin : gm
      logic [31:0] c_mboth;
      assign (highz1, strong0) #2 c_mboth = 32'd7;
    end
  endgenerate
  assign o = u_if.gl.c_both ^ gm.c_mboth;
endmodule
