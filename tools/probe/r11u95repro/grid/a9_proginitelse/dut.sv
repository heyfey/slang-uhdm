// r11u95 a9 -- BOTH arms of an if/else declare an initial.
program prg ();
  wire [31:0] w_plain = 32'd11;
  generate
    if (1) begin : g
      initial begin
        $display("then");
      end
    end else begin : h
      initial begin
        $display("else");
      end
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
