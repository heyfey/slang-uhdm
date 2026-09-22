// r11u95 c7 -- THE CONTROL: a ZERO-iteration loop in an INTERFACE home.
interface ifc ();
  wire [31:0] w_plain = 32'd11;
  generate
    for (genvar i = 0; i < 0; i++) begin : g
      wire [31:0] w_loop = 32'd12;
    end
  endgenerate
endinterface
module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = 32'd0;
endmodule
