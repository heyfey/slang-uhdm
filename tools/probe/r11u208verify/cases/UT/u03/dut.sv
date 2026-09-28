// § unitClassTdSpecAtName202 § classSpecExprArgUnlocated202 § classValueParamIntSigned202
class obj;
endclass
class c3 #(int A = 1, int B = 2, int C = 3);
endclass
class m #(int W = 2, type T = int);
  T v;
endclass
class n #(type T = int, int W = 2);
endclass
typedef c3#(4, 5, 6) t3;
typedef c3#(.B(7), .C(8)) tn;
typedef m#(8, byte) tm;
typedef n#(obj, 4) tq;
module top ();
  t3 a;
  tn b;
  tm c = new;
  tq d;
endmodule
