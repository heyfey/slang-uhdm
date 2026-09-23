interface itf #(parameter bit [7:0] A = 4) ();
  logic [A-1:0] a;
  modport m (input a);
endinterface
module leaf #(parameter int A = 300) (itf.m p);
endmodule
module dut ();
  itf #(8) arr[2] ();
  leaf u (.p(arr[0]));
endmodule
