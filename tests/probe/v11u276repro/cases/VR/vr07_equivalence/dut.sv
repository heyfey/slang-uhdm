// § equivOpIsEqOp276v
module dut #(parameter logic [7:0] P = 8'h3C, parameter logic [7:0] Q = 8'hA5) (input logic [7:0] n, m, output logic [7:0] o);
  assign o = {7'b0, (P[1] & n[1]) <-> m[1]};
endmodule
