package pkg;
  class base;
   int id;
  endclass
class cbs #(type CB=base);
 CB cb;
endclass
endpackage
module top();
pkg::cbs c1;
endmodule
