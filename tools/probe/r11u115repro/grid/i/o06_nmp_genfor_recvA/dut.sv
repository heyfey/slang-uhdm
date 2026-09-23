interface itf #(parameter int A = 16, parameter int B = 32, parameter int C = B, parameter int D = A * 2) ();
  logic [A-1:0] a;
  logic [C-1:0] v;
  logic [D-1:0] d;
  modport m (input a, d, output v);
endinterface
module leaf #(parameter int A = 5) (itf.m p);
  assign p.v = '0;
endmodule
module dut ();
  itf #(8, 32, 64) i ();
  for (genvar k = 0; k < 2; k++) begin : g
    leaf u (.p(i));
  end
endmodule
