package pk;
  parameter int WID = 6;
  typedef logic [WID-1:0] word_t;
endpackage

module \a.b.C (input wire [pk::WID-1:0] x, output wire [pk::WID-1:0] y);
  pk::word_t t;
  assign t = x;
  assign y = t;
endmodule
