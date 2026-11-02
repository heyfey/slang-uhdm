// § clsNestedUnsizedDims464 (shortreal and realtime elements)
class C;
  shortreal d[][];
  realtime q[$][];
endclass
module top;
  initial begin C c; c = new; end
endmodule
