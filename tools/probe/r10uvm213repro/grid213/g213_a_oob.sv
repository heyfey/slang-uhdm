// ARM A — THE LAW.  A PACKAGE class with TYPE PARAMETERS and OUT-OF-BODY
// method definitions: a type-parameter-typed FORMAL, a type-parameter-typed
// subroutine-body LOCAL, and a BLOCK-ITEM local of the same kind.  The
// question is which VIEW of p213a each placeholder's vpiInstance names in each
// of the listings that hold a copy.
package p213a;
  class c213a #(type T213 = int, type U213 = int);
    extern function void fa213(T213 x213);
    extern task ta213(output U213 y213);
    extern function void la213();
  endclass
  function void c213a::fa213(T213 x213);
    T213 loca213;
    loca213 = x213;
  endfunction
  task c213a::ta213(output U213 y213);
    U213 loct213;
    y213 = loct213;
  endtask
  function void c213a::la213();
    T213 lav213;
    begin : blk213
      U213 law213;
      lav213 = law213;
    end
  endfunction
endpackage
module top213a;
  initial begin end
endmodule
