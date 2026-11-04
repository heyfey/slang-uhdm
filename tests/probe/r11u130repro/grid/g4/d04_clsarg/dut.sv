// § classSpecArgNetNoFile130
class base_c;
endclass
class obj #(type T = int, type U = int);
  T t;
  U u;
endclass
module top;
  obj #(base_c, string) o1 = new;
endmodule
