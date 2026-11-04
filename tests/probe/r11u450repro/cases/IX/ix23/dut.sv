// § cloneVarSelBind450
package p;
  task automatic t(int i0);
    logic [3:0][7:0] m;
    for (int j = 0; j < 4; j++) begin
      logic [3:0][7:0] w;
      w[j][i0] = m[j][0];
    end
  endtask
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
