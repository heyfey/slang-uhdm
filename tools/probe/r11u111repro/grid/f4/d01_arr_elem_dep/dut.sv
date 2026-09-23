interface itf #(parameter int A = 16, parameter int B = 32, parameter int C = B) ();
  logic [C-1:0] v;
endinterface
module leaf #(parameter int N = 2) (itf p [N]);
  assign p[0].v = '0;
endmodule
module dut ();
  itf #(8, 32, 64) arr[2] ();
  leaf #(.N(2)) u (.p(arr));
endmodule
