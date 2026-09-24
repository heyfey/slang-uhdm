// r10v122 arm q4 - the SAME body reached through ONE, TWO and THREE instances,
// plus an import CLONE of the same package function.
package Rho3_pkg;
  function automatic int unsigned hashRho(int unsigned seedI);
    bit [31:0] crcR;
    bit msbR;
    crcR = 32'hFFFF_FFFF;
    for (int bx = 0; bx < 4; bx++) begin
      msbR = crcR[31];
      crcR <<= 1;
      if (msbR ^ seedI[bx]) begin
        crcR ^= 32'h04C1_1DB7;
        crcR[0] = 1'b1;
      end
    end
    hashRho = crcR;
  endfunction
endpackage

module LeafRho (input logic [3:0] inW, output logic [31:0] outW);
  import Rho3_pkg::*;
  logic [31:0] hv;
  always_comb begin
    hv = hashRho(32'(inW));
  end
  assign outW = hv;
endmodule

module OneInst (input logic [3:0] a1, output logic [31:0] z1);
  LeafRho u_only (.inW(a1), .outW(z1));
endmodule

module ThreeInst (input logic [3:0] a3, output logic [31:0] z3);
  logic [31:0] w0, w1, w2;
  LeafRho u_first  (.inW(a3),        .outW(w0));
  LeafRho u_second (.inW(a3 ^ 4'h5), .outW(w1));
  LeafRho u_third  (.inW(a3 | 4'h3), .outW(w2));
  assign z3 = w0 ^ w1 ^ w2;
endmodule

module TopRho (input logic [3:0] pin, output logic [31:0] pout);
  logic [31:0] s1, s3;
  OneInst   i_one   (.a1(pin), .z1(s1));
  ThreeInst i_three (.a3(pin), .z3(s3));
  assign pout = s1 ^ s3;
endmodule
