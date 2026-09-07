// r10v192 ARM D — FREE PACKAGE SUBROUTINES MUST NOT GAIN QUALIFIED COPIES,
// across function and task kinds, with a class method of the SAME NAME.
// MEASUREMENT ONLY.
package freeP;
  function automatic int solo();
    return 1;
  endfunction
  task automatic soloT(output int q);
    q = 2;
  endtask

  class Box;
    extern static function int solo();
    extern static task soloT(output int q);
    extern static function int boxCaller();
    extern static task boxCallerT(output int q);
  endclass
  function int Box::solo();
    return 3;
  endfunction
  task Box::soloT(output int q);
    q = 4;
  endtask
  function int Box::boxCaller();
    return solo() + freeP::solo() + Box::solo();
  endfunction
  task Box::boxCallerT(output int q);
    int r;
    soloT(r);
    freeP::soloT(r);
    Box::soloT(q);
  endtask

  // a free function body calling both faces
  function automatic int freeCaller();
    return solo() + Box::solo();
  endfunction
endpackage

module v192d_top;
  import freeP::*;
  int r;
  initial r = freeP::freeCaller();
endmodule
