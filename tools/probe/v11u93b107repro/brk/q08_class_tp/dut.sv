package pk;
  class C #(type T = struct packed { logic a; logic b; });
    T v;
  endclass
endpackage
module dut(input logic [1:0] i, output logic [1:0] o);
  assign o = i;
endmodule
