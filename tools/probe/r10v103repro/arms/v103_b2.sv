// r10v103 arm b2 — HOMES.  The same shell-bearing statement in every scope a
// generic class body can reach: in-body function, in-body task, OUT-OF-BODY
// function/task, static method, inside if / loop / named begin / fork, and in
// a class nested in a package vs a module.  MEASUREMENT ONLY.
package Vb2;

  class Lf2;
    int uu;
    function void put(int aa); uu = aa; endfunction
    task tput(int aa); uu = aa; endtask
    function int get(); return uu; endfunction
  endclass

  class Md2;
    Lf2 slot;
    function new(); slot = new(); endfunction
  endclass

  class Hm2 #(type PT = int);
    Md2 bo;
    PT  tp;
    int kk;
    static Md2 sbo;
    function new(); bo = new(); endfunction

    function void Hfun();  bo.slot.put( tp.conv(kk) );  endfunction
    task         Htsk();   bo.slot.put( tp.conv(kk) );  endtask
    static function void Hsta(); sbo.slot.put( 7 );     endfunction
    extern function void Hoob();
    extern task          Hoot();
    function void Hif();   if (kk > 0) bo.slot.put( tp.conv(kk) ); endfunction
    function void Hfor();  for (int i = 0; i < 2; i++) bo.slot.put( tp.conv(kk) ); endfunction
    function void Hbeg();  begin : bblk bo.slot.put( tp.conv(kk) ); end endfunction
    task Hfrk();  fork bo.slot.put( tp.conv(kk) ); join_none endtask
    task Htim();  #1 bo.slot.put( tp.conv(kk) ); endtask
    function void Hcase(); case (kk) 0: bo.slot.put( tp.conv(kk) ); default: ; endcase endfunction
  endclass

  function void Hm2::Hoob(); bo.slot.put( tp.conv(kk) ); endfunction
  task Hm2::Hoot();          bo.slot.tput( tp.conv(kk) ); endtask

endpackage

module Vb2m;
  class Lf2m;
    int uu;
    function void put(int aa); uu = aa; endfunction
  endclass
  class Md2m;
    Lf2m slot;
    function new(); slot = new(); endfunction
  endclass
  class Hm2m #(type PT = int);
    Md2m bo; PT tp; int kk;
    function new(); bo = new(); endfunction
    function void Mfun(); bo.slot.put( tp.conv(kk) ); endfunction
    extern function void Moob();
  endclass
  function void Hm2m::Moob(); bo.slot.put( tp.conv(kk) ); endfunction
endmodule

program Vb2p;
  class Lf2p;
    int uu;
    function void put(int aa); uu = aa; endfunction
  endclass
  class Md2p;
    Lf2p slot;
    function new(); slot = new(); endfunction
  endclass
  class Hm2p #(type PT = int);
    Md2p bo; PT tp; int kk;
    function new(); bo = new(); endfunction
    function void Pfun(); bo.slot.put( tp.conv(kk) ); endfunction
  endclass
endprogram

interface Vb2i;
  class Lf2i;
    int uu;
    function void put(int aa); uu = aa; endfunction
  endclass
  class Md2i;
    Lf2i slot;
    function new(); slot = new(); endfunction
  endclass
  class Hm2i #(type PT = int);
    Md2i bo; PT tp; int kk;
    function new(); bo = new(); endfunction
    function void Ifun(); bo.slot.put( tp.conv(kk) ); endfunction
  endclass
endinterface
