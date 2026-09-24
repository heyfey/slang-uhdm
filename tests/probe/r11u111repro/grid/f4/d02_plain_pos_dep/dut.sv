interface itf #(parameter int A = 16, parameter int B = 32, parameter int C = B) ();
  logic [C-1:0] v;
endinterface
module leaf (itf p);
  assign p.v = '0;
endmodule
module dut ();
  itf #(8, 32, 64) i ();
  leaf u (i);
endmodule
