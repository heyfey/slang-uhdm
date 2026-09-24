// v20 -- a generate block holding final, initial, always and a class.
module sub ();
  logic clk;
  generate
    if (1) begin : g
      class C; int x; endclass
      initial $display("hi");
      always @(posedge clk) $display("tick");
      final begin
        $display("bye");
      end
    end
  endgenerate
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
