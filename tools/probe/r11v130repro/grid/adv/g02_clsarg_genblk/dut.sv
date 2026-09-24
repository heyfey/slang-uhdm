// § classSpecArgNetNoFile130
class base_c;
endclass
class obj #(type T = int);
  T t;
endclass
module top;
  if (1) begin : g
    obj #(base_c) o1;
  end
  obj #(base_c) o2;
endmodule
