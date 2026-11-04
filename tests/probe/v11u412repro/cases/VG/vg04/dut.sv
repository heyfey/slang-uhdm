// § genericIfacePosConnNoDouble412
interface sb;
  logic [3:0] d;
endinterface
module mem(interface m);
endmodule
module top;
  sb s[2]();
  mem u0(s[0]);
  mem u1(s[1]);
endmodule
