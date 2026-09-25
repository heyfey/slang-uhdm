// § arrQueryFoldAtBound158
module sub (output int o);
  parameter [6:2] a = 0;
  localparam int H = $high(a);
  assign o = H;
endmodule
module dut (output int o, output int q);
  sub u(.o(o));
  sub #(.a(3)) v(.o(q));
endmodule
