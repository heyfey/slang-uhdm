// § ndaRangeQueryFold216 § impPatCopyFirstListingUnparented215 — nets initialized by range queries of an imported packed-struct pattern parameter (whole and a member) and of a ranged imported parameter
package hp;
  typedef struct packed { logic [3:0] a; logic [2:0] b; } s_t;
  parameter s_t PA = '{ a: 4'd9, b: 3'd5 };
  parameter logic [9:2] PR = 8'd3;
endpackage
package ip;
  import hp::*;
  export hp::*;
endpackage
module dut import hp::*; import ip::*; (output logic [7:0] o1, output logic [7:0] o2, output logic [7:0] o3, output logic [6:0] o4);
  wire [7:0] w1 = $high(PA);
  wire [7:0] w2 = $low(PR);
  wire [7:0] w3 = $size(PA);
  assign o1 = w1;
  assign o2 = w2;
  assign o3 = w3;
  assign o4 = PA;
endmodule
