// § procAsgRhsPkgFoldTs471
// program task assigning an imported parameter, program instantiated twice
package a;
  parameter logic [3:0] PA = 4'd3;
endpackage
program prg(output logic [3:0] o);
  import a::*;
  task automatic t(); o = PA; endtask
  initial t();
endprogram
module top(output logic [3:0] y, output logic [3:0] z);
  prg p1(.o(y));
  prg p2(.o(z));
endmodule
