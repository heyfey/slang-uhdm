// § procAsgRhsPkgFoldTs471
// nested module instance three deep, assignment in a fork and a named block
package a;
  parameter logic [2:0] PA = 3'd5;
endpackage
module leaf(output logic [2:0] o);
  import a::*;
  initial begin : nb
    fork
      o = PA;
    join
  end
endmodule
module mid(output logic [2:0] o);
  leaf l(.o(o));
endmodule
module top(output logic [2:0] y);
  mid m(.o(y));
endmodule
