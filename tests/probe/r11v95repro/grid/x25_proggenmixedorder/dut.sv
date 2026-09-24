// v11u93 x25 -- every kind, body and block INTERLEAVED by source order.
program prg ();
  function automatic int f_one(); return 1; endfunction
  initial $display("one");
  generate
    if (1) begin : g
      task automatic t_two(); endtask
      initial $display("two");
      class Ctwo; int x; endclass
      wire [31:0] w_two = 32'd12;
    end
  endgenerate
  task automatic t_three(); endtask
  initial $display("three");
  class Cthree; int y; endclass
  wire [31:0] w_three = 32'd13;
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
