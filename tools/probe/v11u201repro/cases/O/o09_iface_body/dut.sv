// § opCtxBindableTarget201v
interface bus_if(input logic [3:0] a);
  logic [3:0] d;
  wire [3:0] e;
  function automatic logic [3:0] f(input logic [3:0] v); return v + 1; endfunction
  assign d = f(a) + 4'd1;
  assign e = f(a) - 4'd1;
endinterface
module top(input logic [3:0] a, output logic [3:0] o);
  bus_if b(.a(a));
  assign o = b.d ^ b.e;
endmodule
