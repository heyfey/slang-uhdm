module dut #(parameter type A = struct packed { logic a; logic b; }, parameter type B = A, parameter type C = B) (input C i, output C o);
  assign o = i;
endmodule
