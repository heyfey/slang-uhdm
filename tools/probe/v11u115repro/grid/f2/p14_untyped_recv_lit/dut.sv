interface itf #(parameter A = 16, parameter C = A + 0) ();
  logic [A-1:0] a;
  modport m (input a);
endinterface
module leaf #(parameter A = 4'd5) (itf.m p);
endmodule
module dut ();
  itf #(8) arr[2] ();
  leaf u (.p(arr[0]));
endmodule
