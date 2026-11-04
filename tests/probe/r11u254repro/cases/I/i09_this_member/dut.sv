// § shellCallInvocationSpan254 (this. and a class-property receiver, in a task, while and return)
package p;
virtual class wrap; endclass
class fac;
  int arr[4];
  function bit reg1(wrap r); return 1; endfunction
  static function bit reg2(wrap r); return 1; endfunction
  function fac self(); return this; endfunction
  static function fac get(); return null; endfunction
endclass
function automatic bit reg3(wrap r); return 1; endfunction
class c #(type T=int);
  fac factory;
  T rgtry;
  function bit f2();
    while (this.factory.reg1(rgtry)) break;
    return factory.reg1(this.rgtry);
  endfunction
  task t1(); if (factory.reg1(rgtry)) ; endtask
endclass
endpackage
module top; endmodule
