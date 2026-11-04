// § classSpecArgNetNoFile130
class base_c;
endclass
class other_c;
endclass
class obj #(type T = int, type U = int);
  T t;
  U u;
endclass
module top;
  obj #(base_c, other_c) o1 = new;
  obj #(base_c, int) o2 = new;
endmodule
