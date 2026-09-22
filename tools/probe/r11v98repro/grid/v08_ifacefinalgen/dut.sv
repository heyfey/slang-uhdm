// v08 -- a FINAL construct in an INTERFACE's generate block.
interface ifc ();
  wire [31:0] w_plain = 32'd11;
  generate
    if (1) begin : g
      final begin
        $display("bye");
      end
    end
  endgenerate
endinterface
module dut (output logic [31:0] o);
  ifc u_i ();
  assign o = 32'd0;
endmodule
