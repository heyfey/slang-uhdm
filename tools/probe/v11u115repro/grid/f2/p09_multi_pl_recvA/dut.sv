interface itf #(parameter int A = 16, parameter int B = 32, parameter int C = B, parameter int D = A * 2) ();
  logic [A-1:0] a;
  logic [C-1:0] v;
  logic [D-1:0] d;
  modport m (input a, d, output v);
endinterface
module leaf #(parameter int A = 5) (itf p);
endmodule
module dut ();
  itf #(8, 32, 64) i ();
  itf #(9, 32, 64) j ();
  leaf u (.p(i));
  leaf w (.p(j));
endmodule
