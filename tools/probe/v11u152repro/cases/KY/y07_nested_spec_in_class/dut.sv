// § classSpecNestedAtName152
virtual class object#(type T=int);
endclass
class config_db#(type T=int);
endclass
class holder;
  config_db#(object#(longint)) m;
  function void f();
    config_db#(object#(int)) l = new;
  endfunction
endclass
module top ();
  holder h = new;
endmodule
