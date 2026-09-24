module dut #(parameter type T = struct packed { logic [1:0] a; logic b; }) (input T i, output logic [1:0] o);
  assign o = i.a;
endmodule
