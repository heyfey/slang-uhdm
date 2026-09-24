// § classSpecArgNetNoFile130
// case c03: class specialization argument inside a program block
class base_c;
endclass
class obj #(type T = int);
  T t;
endclass
program prg;
  obj #(base_c) o1;
endprogram
module top;
  prg p();
endmodule
