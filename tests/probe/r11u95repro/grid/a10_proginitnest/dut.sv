// r11u95 a10 -- NESTED generate blocks, each with an initial.
program prg ();
  wire [31:0] w_plain = 32'd11;
  generate
    if (1) begin : g
      initial begin
        $display("out");
      end
      if (1) begin : h
        initial begin
          $display("in");
        end
      end
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
