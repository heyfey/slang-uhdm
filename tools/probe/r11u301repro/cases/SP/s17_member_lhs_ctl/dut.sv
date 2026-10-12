// § caSelLhsParamReuseAnyEnc301
module m #(parameter int Z = 5)();
  struct packed { logic [3:0] f; logic [3:0] g; } s;
  assign s.f = Z;
  assign s.g = 4'd0;
endmodule
module dut;
  m u_a();
endmodule
