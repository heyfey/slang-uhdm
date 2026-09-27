package p;
class c;
  int id;
endclass
class k;
  function void f();
    c a[$];
    c b[$];
    b = a.unique( cb_ ) with ( cb_.id );
  endfunction
endclass
endpackage
module top; endmodule
