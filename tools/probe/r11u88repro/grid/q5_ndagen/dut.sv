// r11u88 q5 -- LAW A x the interface's GEN-SCOPE home: a net-decl-assign
// written inside a generate block of an interface.
interface ifc ();
  wire [31:0] w_body = 32'd11;
  generate
    if (1) begin : gl
      wire [31:0] w_gen = 32'd12;
    end
  endgenerate
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.w_body ^ u_if.gl.w_gen;
endmodule
