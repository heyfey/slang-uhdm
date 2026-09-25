// § caDelayFirstOnly164 — a delay list inside an interface
interface itf;
  logic a, b, c;
  assign #2 b = a, c = ~a;
endinterface
module top;
  itf i();
endmodule
