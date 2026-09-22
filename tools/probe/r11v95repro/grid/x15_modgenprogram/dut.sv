// v11u93 x15 -- a PROGRAM instantiated inside a MODULE's generate block.
program prg ();
  wire [31:0] w_plain = 32'd11;
  generate
    if (1) begin : g
      initial $display("hi");
      function automatic int f_gen(); return 7; endfunction
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  generate
    if (1) begin : mg
      prg u_p ();
    end
  endgenerate
  assign o = 32'd0;
endmodule
