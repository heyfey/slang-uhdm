package p;
class item; endclass
class pr #(type T=int); endclass
class cmp #(type T=int, type pair_type = pr #( T ) );
  task run();
    pair_type pair;
    pair = null;
  endtask
endclass
endpackage
module top; endmodule
