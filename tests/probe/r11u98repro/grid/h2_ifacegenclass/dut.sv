// r11u98 h2 -- an INTERFACE home's generate-block class, ALONE (x17 minus the tf).
interface ifc ();
  wire [31:0] w_plain = 32'd11;
  generate
    if (1) begin : g
      class C; int x; endclass
    end
  endgenerate
endinterface
module dut (output logic [31:0] o);
  ifc u_i ();
  assign o = 32'd0;
endmodule
