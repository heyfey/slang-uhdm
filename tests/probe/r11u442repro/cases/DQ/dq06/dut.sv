// § modDynTdDefNetCopy442
module top(output int o);
  typedef int d_t[];
  d_t d;
  assign o = d.size();
endmodule
