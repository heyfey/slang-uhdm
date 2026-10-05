// § methCallNameSpanAcrossLines244
package p;
  virtual class vb;
    pure virtual function int get(int a, int b = 2);
    extern function void run(vb o);
  endclass
  function void vb::run(vb o);
    int z;
    z = o .get(1);
    z = o.
        get(.a(1), .b());
    z = o. get(.a(o. get(3)));
  endfunction
  class cc extends vb;
    function int get(int a, int b = 2); return a + b; endfunction
  endclass
endpackage
module top; p::cc u; initial u = new(); endmodule
