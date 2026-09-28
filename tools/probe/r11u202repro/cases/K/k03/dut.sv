// § modGenericClassListedAtDefault200
program prg;
  class gbox #(parameter int W = 4); logic [W-1:0] v; endclass
  class aplain; int a; endclass
  gbox #(8) b;
  aplain p;
endprogram
module top; endmodule
