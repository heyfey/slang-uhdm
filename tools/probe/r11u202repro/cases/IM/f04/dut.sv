// § modportExprPort
interface tif;
  logic a;
  logic b;
  modport sub (input a, input b);
endinterface
module inner (input logic x, output logic o);
  assign o = x;
endmodule
module wrapper (tif sub, output logic o);
  inner u (.x(sub.a | sub.b), .o(o));
endmodule
module top (input logic p, output logic o);
  tif s();
  assign s.a = p;
  assign s.b = p;
  wrapper w (.sub(s), .o(o));
endmodule
