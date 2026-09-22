// v11u93 x20 -- a TOP-LEVEL program: a class and a task in its generate block.
program prg ();
  wire [31:0] w_plain = 32'd11;
  generate
    if (1) begin : g
      class C; int x; endclass
      task automatic t_gen(); endtask
      final $display("bye");
    end
  endgenerate
endprogram
