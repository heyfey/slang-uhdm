// § modportExprPort
interface tif;
  logic a;
  logic b;
  modport sub (input a, input b);
endinterface
module inner (input logic x, output logic o);
  assign o = x;
endmodule
module wrapper (tif.sub sub, output logic o1, output logic o2);
  inner u (.x(sub.a & sub.b), .o(o1));
  inner v (.x(~sub.a), .o(o2));
endmodule
module top (input logic p, output logic o1, o2);
  tif s();
  assign s.a = p;
  assign s.b = p;
  wrapper w (.sub(s.sub), .o1(o1), .o2(o2));
endmodule
