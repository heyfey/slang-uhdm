// § classSpecArgNetNoFile130
class base_c;
endclass
class obj #(type T = int);
  T t;
endclass
module sub;
  obj #(base_c) o1;
endmodule
module top;
  sub u();
endmodule
