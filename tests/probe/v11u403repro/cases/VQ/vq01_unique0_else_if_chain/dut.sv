// § unique0IfIsUnique403
module top(input [1:0] s, output logic [1:0] y);
  always_comb unique0 if (s == 0) y = 1; else if (s == 1) y = 2; else y = 3;
endmodule
