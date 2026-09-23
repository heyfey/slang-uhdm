interface itf #(parameter logic [7:0] A = 8'h10, parameter int B = 32) ();
  logic [A-1:0] a;
  modport m (input a);
endinterface
module leaf (itf.m p);
endmodule
module dut ();
  itf #(8'h08, 40) arr[2] ();
  leaf u (.p(arr[0]));
endmodule
