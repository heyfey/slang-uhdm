interface itf #(parameter int A = 16, parameter int B = 32, parameter int C = B, parameter int D = A * 2) ();
  logic [A-1:0] a;
  logic [C-1:0] v;
  logic [D-1:0] d;
  modport m (input a, d, output v);
endinterface
module leaf (itf.m p);
endmodule
module dut ();
  itf i ();
  if (1) begin : g
    leaf u (.p(i));
  end
endmodule
