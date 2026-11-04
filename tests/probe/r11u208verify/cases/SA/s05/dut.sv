// § sysCtxRefArgBare201
module s05 (input logic [3:0] a, input logic [7:0] w, output logic [7:0] y1, output logic [7:0] y2, output int y3, output int y4);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  assign y1 = $signed(f(a));
  assign y2 = $unsigned(f(w[3:0]));
  assign y3 = $clog2(f(a));
  assign y4 = $countones($signed(f(a)));
endmodule
