// § hoistPoolSourceOrder240: a derived class in a second package reads an inherited property beside its own
package p1;
  class base;
    int cnt;
    int own;
    extern function int bget();
  endclass
  function int base::bget();
    return own;
  endfunction
endpackage
package p2;
  import p1::*;
  class zd extends base;
    int mine;
    extern function int dget();
    extern function new();
  endclass
  function zd::new();
    mine = 3;
  endfunction
  function int zd::dget();
    return cnt + mine;
  endfunction
  class ad;
    int mine;
    extern task t();
  endclass
  task ad::t();
    mine = 1;
  endtask
endpackage
module top;
  import p1::*;
  import p2::*;
  initial $display("x");
endmodule
