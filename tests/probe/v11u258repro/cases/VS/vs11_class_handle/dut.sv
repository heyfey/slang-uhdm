// § lvStreamBaseKeepsActual258 (a class handle's property range select as a streaming target in a module initial)
class c; logic [7:0] f; endclass
module top; c h; logic [3:0] x;
  initial begin h = new; {>>{h.f[3:0]}} = x; end
endmodule
