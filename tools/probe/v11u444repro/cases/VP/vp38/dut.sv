// § portNameLocalNoTs444v
program prg(input logic clk, output logic [3:0] o);
function automatic logic f();
  logic [3:0] o;
  o = 4'h1;
  return o[0];
endfunction
initial begin logic r; r = f(); end
endprogram
