module top(input logic [3:0] a, output logic [3:0] y);
  (* real_attr = 1.5, r2 = 2.25, r3 = 3.0, r4 = 1.0e-3, i = 42, s = "x" *)
  wire [3:0] w = a;
  assign y = w;
endmodule
