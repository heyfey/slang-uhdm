// § implicitPortPaLastNoBody405
module top #(c = 3, localparam d = c + 1, e = 7) (output int o);
  assign o = c + d + e;
endmodule
