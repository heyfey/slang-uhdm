// r11u95 c2 -- THE CONTROL: the same initial-in-generate in an INTERFACE home.
interface ifc ();
  wire [31:0] w_plain = 32'd11;
  generate
    if (1) begin : g
      wire [31:0] w_gen = 32'd12;
      initial begin
        $display("hi");
      end
    end
  endgenerate
endinterface
module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = 32'd0;
endmodule
