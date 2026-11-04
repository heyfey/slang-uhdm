package pkg;
  class base;
   int id;
  endclass
class cbs #(type CB=base);
 function void get_all(CB a);
  a = null;
 endfunction
endclass
endpackage
module top();
pkg::cbs c1;
endmodule
