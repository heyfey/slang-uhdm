// § sysCtxRefArgBare201
module top(input logic [7:0] a, output logic [31:0] y1, output logic [31:0] y2);
  function automatic logic [3:0] f(input logic [3:0] v); return v + 1; endfunction
  always_comb y1 = $countones(f(a[3:0]));
  wire [31:0] w = $countones(f(a[7:4]));
  assign y2 = w;
endmodule
