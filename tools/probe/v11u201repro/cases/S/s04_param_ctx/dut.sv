// § sysCtxRefArgBare201
module top #(parameter logic [7:0] PA = 8'h35) (input logic [7:0] a, output logic [31:0] y1, output logic [31:0] y2);
  function automatic logic [3:0] f(input logic [3:0] v); return v + 1; endfunction
  localparam int LP = $countones(f(PA[3:0]));
  assign y1 = LP;
  assign y2 = $countones(f(PA[3:0])) + $countones(f(a[3:0]));
endmodule
