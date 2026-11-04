// § tpPackedArrCaUnparent275 — two definitions sharing nothing, one assigning
module ca #(parameter type T = struct packed { logic a; logic b; } [1:0]) (input T i, output T o);
  assign o = i;
endmodule
module cb #(parameter type T = struct packed { logic a; logic b; } [1:0]) (input T i, output T o);
  always_comb o = i;
endmodule
module dut (input logic [3:0] i, output logic [3:0] o1, o2);
  ca u (.i(i), .o(o1));
  cb w (.i(i), .o(o2));
endmodule
