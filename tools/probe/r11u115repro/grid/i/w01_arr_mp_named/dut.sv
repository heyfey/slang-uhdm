interface itf #(parameter int A = 16, parameter int B = 32, parameter int C = B) ();
  logic [A-1:0] a;
  logic [C-1:0] v;
  modport m (input a, output v);
endinterface
module leaf (itf.m p [2]);
  assign p[0].v = '0;
endmodule
module dut ();
  itf #(8, 32, 64) arr[2] ();
  leaf u (.p(arr));
endmodule
