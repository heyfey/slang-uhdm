// v11u93 x14 -- TWO separate generate blocks, both kinds in each, ORDER.
program prg ();
  function automatic int f_body(); return 3; endfunction
  generate
    if (1) begin : ga
      function automatic int f_a(); return 7; endfunction
      initial $display("a");
    end
  endgenerate
  initial $display("body");
  generate
    if (1) begin : gb
      task automatic t_b(); endtask
      final $display("b");
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
