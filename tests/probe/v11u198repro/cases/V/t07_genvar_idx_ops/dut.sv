// § callArgVarSelStamp198
module top (input logic c, input logic [3:0] p [2][4], input logic [3:0] pp [2][2][2], input logic [3:0] p1 [4], output logic [3:0] y, output logic [3:0] y2 [2][4], output logic [3:0] z);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  for (genvar i = 0; i < 2; i++) begin : g
    for (genvar j = 0; j < 4; j++) begin : h
      assign y2[i][j] = f(p[i][3-j]);
    end
  end
endmodule
