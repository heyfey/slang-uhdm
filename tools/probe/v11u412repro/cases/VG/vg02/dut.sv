// § genericIfacePosConnNoDouble412
interface sb;
  logic [3:0] d;
endinterface
module mem(interface m);
endmodule
module top;
  sb s1();
  sb s2();
  mem u1(s1);
  mem u2(.m(s2));
endmodule
