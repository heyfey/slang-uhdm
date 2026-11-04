module a (output logic [4:2] a1, output logic a2);
endmodule
module b (output logic b1);
  a a_inst(.a1(b2), .a2(b1));
  assign b2 = 'b0;
endmodule
module top (output logic out);
  b inst (.b1(out));
endmodule
