// § classSpecArgNetNoFile130
// case c02: two variables specialized with the same bare class argument
class base_c;
endclass
class obj #(type T = int);
  T t;
endclass
module top;
  obj #(base_c) o1;
  obj #(base_c) o2;
endmodule
