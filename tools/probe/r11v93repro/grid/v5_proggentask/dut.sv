// v11u93 v5 -- a FUNCTION and a TASK inside a PROGRAM's generate block.
program prg ();
  wire [31:0] w_plain = 32'd11;
  generate
    if (1) begin : g
      function automatic int f_gen(); return 7; endfunction
      task automatic t_gen(); endtask
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
