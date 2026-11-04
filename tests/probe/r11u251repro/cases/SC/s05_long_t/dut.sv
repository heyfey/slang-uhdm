// § ppStrEndNotTokStart251
`define M(F, T) \
  do begin \
    $display(`"F`", 1, `"T``(string)`"); \
  end while(0)
module top; initial `M(abc, dadadada); endmodule
