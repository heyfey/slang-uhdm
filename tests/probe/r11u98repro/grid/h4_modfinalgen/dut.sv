// r11u98 h4 -- c8 re-run: a final construct in a MODULE's generate block.
module sub ();
  wire [31:0] w_plain = 32'd11;
  generate
    if (1) begin : g
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
