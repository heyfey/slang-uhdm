// r11u95 a19 -- a TOP-LEVEL program whose generate block holds an initial.
program prg ();
  wire [31:0] w_plain = 32'd11;
  generate
    if (1) begin : g
      wire [31:0] w_gen = 32'd12;
      initial begin
        $display("hi");
      end
    end
  endgenerate
endprogram
