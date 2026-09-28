// § unitClassTdSpecAtName202
class cfg#(type T=int, int W=3);
endclass
typedef cfg#() m0;
typedef cfg#(.T(byte)) m1;
typedef cfg#(int, 4) m2;
typedef cfg
   #(shortint,
     5) m3;
module top ();
  m0 a;
  m1 b;
  m2 c;
  m3 d = new;
endmodule
