// § cloneFormalTsParented253 (downstream: a parameter-ranged formal in a function called through an importer)
package p;
  parameter W = 8;
  function automatic logic [W-1:0] inc(input logic [W-1:0] v);
    return v + 1'b1;
  endfunction
  function automatic logic [W-1:0] pick;
    input logic [W-1:0] a;
    logic [W-1:0] r;
    r = a << 1;
    return r;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top(input logic [7:0] a, output logic [7:0] y, output logic [7:0] z);
  import p::*;
  assign y = inc(a);
  assign z = pick(a);
endmodule
