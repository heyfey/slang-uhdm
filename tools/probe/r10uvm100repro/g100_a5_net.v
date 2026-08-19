// r10uvm100 arm a5 -- the NON-statement delay positions (Verilog): net-decl
// delay, gate delay, continuous-assign delay -- the compileDelayControl path
// that must NOT gain a Delay ref.
module m5a(input x5, output y5);
  parameter Tp5 = 2;
  wire #(Tp5) w5 = x5;
  wire #3 v5 = x5;
  wire #(Tp5 + 1) u5 = x5;
  assign #(Tp5) y5 = x5;
  assign #4 t5 = x5;
  and #(Tp5) g5 (s5, x5, x5);
  and #2 g6 (r5, x5, x5);
  buf #(Tp5, Tp5) g7 (q5, x5);
endmodule
