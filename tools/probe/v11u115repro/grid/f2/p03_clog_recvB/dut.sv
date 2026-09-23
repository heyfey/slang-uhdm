interface itf #(parameter int B = 32, parameter int C = $clog2(B)) ();
  logic [C-1:0] v;
  modport m (input v);
endinterface
module leaf #(parameter int B = 256) (itf.m p);
endmodule
module dut ();
  itf #(64, 9) arr[2] ();
  leaf u (.p(arr[0]));
endmodule
