// § opCtxRefArgBare201
module top(input logic [3:0] a, output logic [3:0] o);
  function automatic logic [3:0] f(input logic [3:0] v); return v + 1; endfunction
  wire [3:0] wa [2];
  logic [3:0] va [2];
  assign wa = '{f(a) + 4'd1, 4'd0};
  assign va = '{f(a) - 4'd1, 4'd2};
  assign o = wa[0] ^ va[1];
endmodule
