// ARM E — THE NON-PACKAGE HOME.  A class declared in a MODULE with out-of-body
// method definitions.  `component->getUhdmInstance()` is not a package here, so
// golden's placeholder must carry NO vpiInstance and the law must not fire.
module top213e;
  class c213e #(type T213 = int);
    extern function void fe213(T213 x213);
  endclass
  function void c213e::fe213(T213 x213);
    T213 loce213;
    loce213 = x213;
  endfunction
  initial begin end
endmodule
