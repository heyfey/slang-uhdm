// § tfArgScalarTdWriter223
package p;
  typedef longint UVM_FILE;
endpackage
program prg;
  import p::*;
  function void f(UVM_FILE x);
  endfunction
  initial f(1);
endprogram
module top;
  import p::*;
  UVM_FILE g;
endmodule
