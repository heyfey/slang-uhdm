interface itf #(parameter int A = 16, parameter int B = 32, parameter int C = B) ();
  logic [A-1:0] a;
  logic [C-1:0] v;
  modport m (input a, output v);
endinterface
module leaf (itf.m p);
  assign p.v = '0;
endmodule
module dut ();
  itf #(8, 32, 64) arr[2] ();
  for (genvar k = 0; k < 2; k++) begin : g
    leaf u (.p(arr[k]));
  end
endmodule
