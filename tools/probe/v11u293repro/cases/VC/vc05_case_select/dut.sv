// § cloneRetNameSelRefBindsHomeReturn293
// The select write inside a case statement.
package p1;
  function logic [7:0] f(input int k);
    f = 8'h0;
    case (k)
      0: f[0] = 1'b1;
      default: f[7] = 1'b1;
    endcase
    f = f - 8'd1;
  endfunction
endpackage
package p2;
  import p1::*;
  function logic [7:0] g();
    return f(1);
  endfunction
endpackage
module top;
  import p2::*;
  int r_o;
  initial r_o = int'(g());
endmodule
