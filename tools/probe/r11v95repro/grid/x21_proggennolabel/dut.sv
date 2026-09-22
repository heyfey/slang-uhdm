// v11u93 x21 -- an UNLABELLED generate block in a program.
program prg ();
  wire [31:0] w_plain = 32'd11;
  generate
    if (1) begin
      wire [31:0] w_gen = 32'd12;
      initial $display("hi");
      function automatic int f_gen(); return 7; endfunction
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
