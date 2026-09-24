module child #(parameter type T = logic [3:0]) (input T a, output T b);
  assign b = ~a;
endmodule
module dut (input logic [3:0] a, output logic [3:0] b);
  child u (.a(a), .b(b));
endmodule
