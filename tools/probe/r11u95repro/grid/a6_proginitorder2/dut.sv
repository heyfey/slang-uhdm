// r11u95 a6 -- a generate-block initial ABOVE a BODY initial (ORDER).
program prg ();
  wire [31:0] w_plain = 32'd11;
  generate
    if (1) begin : g
      initial begin
        $display("gen");
      end
    end
  endgenerate
  initial begin
    $display("body");
  end
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
