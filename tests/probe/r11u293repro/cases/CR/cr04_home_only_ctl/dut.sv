// § cloneRetNameSelRefBindsHomeReturn293
// CONTROL: no wildcard importer, so no clone body: the home's select binding stays.
package p1;
  function logic [7:0] f();
    f = 8'h0;
    f[2] = 1'b1;
    f = f ^ 8'h3;
  endfunction
endpackage
module top;
  int r_o;
  initial r_o = int'(p1::f());
endmodule
