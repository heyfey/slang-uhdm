// r11u93 pa17 -- the program is a TOP-LEVEL program with a generate block.
program prg ();
  wire [31:0] w_plain = 32'd11;
  generate
    if (1) begin : g
      wire [31:0] w_gen = 32'd12;
    end
  endgenerate
endprogram
