// r11u95 a22 -- TWO instances of the same program: which elab view wins the
// first-writer stamp.
program prg ();
  function automatic int f_body(); return 3; endfunction
  generate
    if (1) begin : g
      function automatic int f_gen(); return 7; endfunction
      initial begin
        $display("hi");
      end
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p1 ();
  prg u_p2 ();
  assign o = 32'd0;
endmodule
