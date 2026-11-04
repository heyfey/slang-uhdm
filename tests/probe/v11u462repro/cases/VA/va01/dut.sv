// § clsMethodOwnAutomatic462
class C;
  extern function int f(int a);
  extern task t();
endclass
function automatic int C::f(int a);
  return a + 1;
endfunction
task automatic C::t();
endtask
module top;
  initial begin C c; c = new; end
endmodule
