package pk; parameter int PW = 12; endpackage
interface itf import pk::*; #(parameter int A = 16, parameter int C = PW) ();
  logic [C-1:0] v;
  modport m (input v);
endinterface
module leaf (itf.m p);
endmodule
module dut ();
  itf #(8, 20) arr[2] ();
  leaf u (.p(arr[0]));
endmodule
