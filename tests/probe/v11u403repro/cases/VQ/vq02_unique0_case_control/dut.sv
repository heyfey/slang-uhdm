// § unique0IfIsUnique403
module top(input [1:0] s, output logic [1:0] y);
  always_comb begin
    y = 0;
    unique0 case (s) 0: y = 1; 1: y = 2; endcase
    unique0 if (s == 3) y = 3;
  end
endmodule
