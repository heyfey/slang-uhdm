// r11u95 a5 -- a BODY initial ABOVE a generate-block initial (ORDER).
program prg ();
  wire [31:0] w_plain = 32'd11;
  initial begin
    $display("body");
  end
  generate
    if (1) begin : g
      initial begin
        $display("gen");
      end
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
