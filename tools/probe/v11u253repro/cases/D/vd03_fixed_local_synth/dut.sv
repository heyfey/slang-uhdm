// § cloneTfFixedArrTsParented253 (downstream: a fixed-size local in a function called through an importer)
package p;
  function automatic logic [7:0] sum4(input logic [7:0] v);
    logic [7:0] a[4];
    logic [7:0] s;
    s = 0;
    for (int i = 0; i < 4; i++) a[i] = v + i;
    for (int i = 0; i < 4; i++) s = s + a[i];
    return s;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top(input logic [7:0] v, output logic [7:0] y);
  import p::*;
  assign y = sum4(v);
endmodule
