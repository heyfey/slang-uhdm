// v11u93 x2 -- a CONCURRENT ASSERTION inside a PROGRAM's generate block.
program prg (input logic clk);
  wire [31:0] w_plain = 32'd11;
  generate
    if (1) begin : g
      assert property (@(posedge clk) 1'b1);
    end
  endgenerate
endprogram
module dut (input logic clk, output logic [31:0] o);
  prg u_p (clk);
  assign o = 32'd0;
endmodule
