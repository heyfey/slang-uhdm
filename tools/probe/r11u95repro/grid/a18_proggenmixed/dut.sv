// r11u95 a18 -- EVERY member kind at once inside one program generate block.
program prg ();
  wire [31:0] w_plain = 32'd11;
  generate
    if (1) begin : g
      wire [31:0] w_gen = 32'd12;
      class C; int x; endclass
      function automatic int f_gen(); return 7; endfunction
      initial begin
        $display("hi");
      end
      task automatic t_gen(); endtask
      final begin
        $display("bye");
      end
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
