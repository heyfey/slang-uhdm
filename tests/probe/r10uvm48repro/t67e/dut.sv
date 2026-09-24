// r10uvm48 arm t67e — the halves the SHIPPED code reaches but t67a..t67d never
// spelled.  Every one of these is a step the walk in § staticScopedChainDrops48
// takes (RangeSelect, a call in the MIDDLE of the chain) or a context its
// § staticScopedLvalueBad48 branch enters (`inLhs` still set while an INDEX
// sub-expression is emitted), so leaving them unmeasured would be exactly this
// campaign's "a law that only ever saw one spelling" trap:
//
//  I1  `y = base67::sbits[3:1];`      class-static PART-SELECT read
//  I2  `base67::sbits[3:1] = 3'b0;`   class-static PART-SELECT lvalue
//  I3  `y = base67::sbits[k +: 2];`   class-static INDEXED part-select read
//  I4  `arr[base67::stat.hval] = 3;`  the chain INSIDE another lvalue's INDEX —
//                                     `inLhs` is still true there
//  I6  `y = base67::stat.get_scope().val;`  a CALL in the MIDDLE of the chain
package p67;

  class mid67;
    int val;
  endclass

  class holder67;
    mid67 scope = new();
    int hval;
    function mid67 get_scope();
      return scope;
    endfunction
  endclass

  class base67;
    static holder67 stat = new();
    static logic [7:0] sbits;
  endclass

  class rdr67;
    int y;
    int arr[0:3];
    function void i1();
      y = base67::sbits[3:1];
    endfunction
    function void i2();
      base67::sbits[3:1] = 3'b0;
    endfunction
    function void i3(int k);
      y = base67::sbits[k +: 2];
    endfunction
    function void i4();
      arr[base67::stat.hval] = 3;
    endfunction
    function void i6();
      y = base67::stat.get_scope().val;
    endfunction
  endclass

endpackage

module t67e;
  import p67::*;
  initial begin
    rdr67 r;
    r = new();
    r.i1();
    r.i2();
    r.i3(1);
    r.i4();
    r.i6();
    $display("%0d", r.y);
  end
endmodule
