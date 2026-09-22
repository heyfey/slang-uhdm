// v11u93 x22 -- a conditional generate with NO generate/endgenerate keywords.
program prg ();
  wire [31:0] w_plain = 32'd11;
  if (1) begin : g
    wire [31:0] w_gen = 32'd12;
    initial $display("hi");
    task automatic t_gen(); endtask
  end
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
