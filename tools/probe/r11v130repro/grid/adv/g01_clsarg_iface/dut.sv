// § classSpecArgNetNoFile130
class base_c;
endclass
class obj #(type T = int);
  T t;
endclass
interface bus;
  obj #(base_c) o1;
  logic d;
endinterface
module top;
  bus b();
endmodule
