// § foreachArrayNamesClass417
class b;
  int v;
endclass
class A;
  rand int b[3];
  constraint c { foreach (b[i]) b[i] < 10; }
endclass
module top;
endmodule
