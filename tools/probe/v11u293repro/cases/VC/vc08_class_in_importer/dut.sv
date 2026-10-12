// § cloneRetNameSelRefBindsHomeReturn293
// The clone called from a class method of the importer.
package p1;
  function logic [7:0] f();
    f = 8'h0;
    f[2] = 1'b1;
    f = f * 2;
  endfunction
endpackage
package p2;
  import p1::*;
  class K;
    function logic [7:0] m();
      return f();
    endfunction
  endclass
endpackage
module top;
  import p2::*;
  int r_o;
  initial begin
    K k = new();
    r_o = int'(k.m());
  end
endmodule
