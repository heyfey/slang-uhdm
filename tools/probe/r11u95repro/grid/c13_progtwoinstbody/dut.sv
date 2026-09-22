// r11u95 c13 -- THE CONTROL for a22: a program BODY initial with TWO
// instances.  Which instance's copy the DEF view keeps is a PRE-EXISTING
// choice, unchanged by this pass.
program prg ();
  initial begin
    $display("hi");
  end
endprogram
module dut (output logic [31:0] o);
  prg u_p1 ();
  prg u_p2 ();
  assign o = 32'd0;
endmodule
