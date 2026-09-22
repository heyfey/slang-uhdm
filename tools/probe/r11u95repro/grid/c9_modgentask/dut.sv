// r11u95 c9 -- THE CONTROL: a function and a task in a MODULE's generate block.
module sub ();
  wire [31:0] w_plain = 32'd11;
  generate
    if (1) begin : g
      function automatic int f_gen(); return 7; endfunction
      task automatic t_gen(); endtask
    end
  endgenerate
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
