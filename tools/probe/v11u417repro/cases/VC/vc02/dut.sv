// § foreachIfaceClassAbstain417v
interface class b;
  pure virtual function int f();
endclass
module top;
  int b[3];
  int n;
  initial foreach (b[i]) n += i;
endmodule
