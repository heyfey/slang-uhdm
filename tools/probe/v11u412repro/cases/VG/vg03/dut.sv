// § genericIfacePosConnNoDouble412
interface sb;
  logic [3:0] d;
  modport mp(output d);
endinterface
module mem(interface.mp m);
  assign m.d = 4'd3;
endmodule
module top(output logic [3:0] y);
  sb s();
  mem u(s);
  assign y = s.d;
endmodule
