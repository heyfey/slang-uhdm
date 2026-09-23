module child(input var struct packed { logic a; logic b; } [1:0] x, output logic [3:0] o);
  assign o = x;
endmodule
module dut(input logic [3:0] i, output logic [3:0] o);
  child u(.x(i), .o(o));
endmodule
