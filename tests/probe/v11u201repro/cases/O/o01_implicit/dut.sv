// § opCtxBindableTarget201v
`default_nettype wire
module top(input logic [3:0] a, output logic [3:0] o);
  function automatic logic [3:0] f(input logic [3:0] v); return v + 1; endfunction
  assign yi = f(a) + 4'd1;
  assign o = yi;
endmodule
