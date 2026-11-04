// § classKwParamsLast412
class Base #(int X = 1, parameter Y = 2);
endclass
class D #(parameter Z = 3, int Q = 4) extends Base #(Z, Q);
endclass
module top;
  D d;
endmodule
