// § sysCtxRefArgBare201 § dfltArgTaintExec204v § evalFuncOmittedDefaultKeepsCall196
module x01 (input logic [3:0] a, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3);
  function automatic logic [3:0] f(input logic [3:0] x, input logic [3:0] b = 4'd1);
    if (b > 0) return ~x;
    return x;
  endfunction
  localparam logic [3:0] L = f(4'd3);
  assign y1 = $countones(f(a));
  assign y2 = $countones(f(4'd5)) + L;
  assign y3 = $countones(f(a[3:0], a));
endmodule
