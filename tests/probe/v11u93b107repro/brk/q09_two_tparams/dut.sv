module dut #(parameter type A = struct packed { logic a; logic b; }, parameter type B = struct packed { logic [2:0] c; }) (input A i, input B j, output A o, output B p);
  assign o = i;
  assign p = j;
endmodule
