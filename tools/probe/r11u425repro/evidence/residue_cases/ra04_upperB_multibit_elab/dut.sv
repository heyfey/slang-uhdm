// this ground, decoded not written: an elaborated param_assign of an x-bearing or unsized uppercase-B binary default respells 4'b10x1 / 'b101 (golden), ours keeps 4'B10x1 / 'B101; a signed 4'SB1010 is INT:10 in golden
module top #(parameter P = 4'B10x1, parameter Q = 8'HFF, parameter R = 4'D9, parameter S = 6'O17, parameter T = 'B101, parameter U = 4'b1010, parameter V = 8'hAb, parameter W = 4'SB1010)(input a, output [7:0] o);
  assign o = Q & 8'HF0;
endmodule
