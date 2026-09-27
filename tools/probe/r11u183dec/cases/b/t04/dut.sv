package pkg;
class cbs #(type CB=int);
 function void get_all();
  CB cb;
  cb = 0;
 endfunction
endclass
endpackage
module top();
pkg::cbs c1;
endmodule
