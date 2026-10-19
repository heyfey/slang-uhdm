// § unitTaskNotListed408
class C;
  extern task t(output int o);
  extern function int f();
endclass
task C::t(output int o);
  o = 1;
endtask
function int C::f();
  return 2;
endfunction
task automatic free_t; endtask
module top;
  C h;
  initial h = new;
endmodule
