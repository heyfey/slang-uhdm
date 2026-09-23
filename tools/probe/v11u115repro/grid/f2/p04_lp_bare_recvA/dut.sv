interface itf #(parameter int A = 16) ();
  localparam int L = A;
  logic [L-1:0] a;
  modport m (input a);
endinterface
module leaf #(parameter int A = 5) (itf.m p);
endmodule
module dut ();
  itf #(8) arr[2] ();
  leaf u (.p(arr[0]));
endmodule
