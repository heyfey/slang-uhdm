// § sysCtxRefArgBare201
module top(input logic [7:0] a, input logic [7:0] w, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3, output logic [31:0] y4);
  function automatic logic [3:0] f(input logic [3:0] v); return v + 1; endfunction
  assign y1 = $bits(f(a[3:0]));
  assign y2 = $size(f(w[3:0]));
  assign y3 = $signed(f(a[3:0])) + $unsigned(f(w[7:4]));
  assign y4 = $clog2(f(a[3:0]));
endmodule
