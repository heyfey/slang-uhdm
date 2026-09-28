// § modSpecValueArgSpanAtName202
class o; endclass
class c #(parameter int W = 4);
  logic [W-1:0] v;
endclass
class b #(type T = int);
  T v;
endclass
class m #(int W = 2, type T = int);
  T v;
endclass
module top;
  c #(8) h = new;
endmodule
