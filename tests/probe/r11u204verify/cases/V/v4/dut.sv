// § callArgVarSelStamp198 § vsStampReducedCtxOnly198v: an operation above a reducing system call, an operation with a stamped and a reduced call as operands, a user call as a process right side
module top (input logic clk, input logic [3:0] p [2][4], output logic [3:0] y1, y2, output logic [3:0] y3);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  assign y1 = $signed(f(p[1][2])) + 1;
  assign y2 = f(p[1][2]) & $unsigned(f(p[0][1]));
  always_ff @(posedge clk) y3 <= f(p[1][3]);
endmodule
