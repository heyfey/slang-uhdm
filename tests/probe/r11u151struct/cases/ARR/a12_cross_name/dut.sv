// ARR: a control: the select Lhs names another variable.
module top(input logic a, output logic [3:0] y);
  logic [3:0] v, w;
  always_comb begin
    w[0] = a;
    w[3:1] = 3'b0;
    v = 4'h1;
    y = v ^ w;
  end
endmodule
