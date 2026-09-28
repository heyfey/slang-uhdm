// § sysCtxRefArgBare201
module sub(input logic [7:0] a, output logic [31:0] y);
  function automatic logic [3:0] f(input logic [3:0] v); return v + 2; endfunction
  for (genvar i = 0; i < 2; i++) begin : g
    logic [31:0] t;
    assign t = $countones(f(a[i+3:i]));
  end
  assign y = g[0].t + $isunknown(f(a[3:0]));
endmodule
module top(input logic [7:0] a, output logic [31:0] y);
  sub u(.a(a), .y(y));
endmodule
