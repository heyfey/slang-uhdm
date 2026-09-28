// § connSysCallArgDefNet193
module sub (input [6:0] d, output logic [7:0] o);
  assign o = 8'(d);
endmodule
module dut #(parameter int W = 9) (output logic [7:0] o);
  sub u (.d($clog2(W)), .o(o));
endmodule
