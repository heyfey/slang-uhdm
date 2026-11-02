// § unitImpTfNameDedup464 (the importing package declares its own f beside the imported f)
package p;
  function automatic int f(int x); return x + 1; endfunction
endpackage
package q;
  import p::*;
  function automatic int f(int x); return x + 5; endfunction
endpackage
import q::*;
import p::*;
module top(input logic [1:0] i, output logic [1:0] o);
  assign o = i;
endmodule
