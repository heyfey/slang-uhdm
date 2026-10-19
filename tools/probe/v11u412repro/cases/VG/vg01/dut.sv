// § genericIfacePosConnNoDouble412
interface sb;
  logic [3:0] d;
  logic v;
endinterface
module mem(interface m, input logic [3:0] x);
  assign m.d = x;
endmodule
module top(input logic [3:0] x, output logic [3:0] y);
  sb s();
  mem u(s, x);
  assign y = s.d;
endmodule
