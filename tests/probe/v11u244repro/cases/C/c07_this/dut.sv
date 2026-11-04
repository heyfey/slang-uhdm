// § methCallNameSpanAcrossLines244
package p;
  class b0; virtual function void hook(); endfunction endclass
  class c1 extends b0;
    c1 o;
    function void hook(); endfunction
    function void run();
      this .hook();
      super .hook();
      this.o .hook();
      this.
        hook();
    endfunction
  endclass
endpackage
module top; p::c1 u; initial u = new(); endmodule
