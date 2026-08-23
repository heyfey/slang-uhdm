module d02_child #(parameter IB = 'b101) ();
  localparam IL = 'o17;
endmodule
module d02;
  d02_child a();
  d02_child b();
  d02_child c();
endmodule
