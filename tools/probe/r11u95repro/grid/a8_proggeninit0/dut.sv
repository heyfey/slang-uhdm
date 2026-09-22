// r11u95 a8 -- an INITIAL inside an UNTAKEN if(0) generate arm.
program prg ();
  wire [31:0] w_plain = 32'd11;
  generate
    if (0) begin : g
      wire [31:0] w_gen = 32'd12;
      initial begin
        $display("hi");
      end
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
