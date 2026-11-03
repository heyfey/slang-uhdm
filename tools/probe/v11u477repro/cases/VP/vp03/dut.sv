// § parenCallWrittenArgs477
module top(output int z, output int y);
  logic [7:0] v;
  initial begin z = ($clog2(8)); y = ($bits(v)); end
endmodule
