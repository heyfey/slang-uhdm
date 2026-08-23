// r10vbuvm27 ARM D -- POSITIONS for $bits(<binary with select left>)
package pD2;
  class CD;
    byte unsigned dyn [];
    logic [7:0]   pk4 [4];
    byte unsigned be;
    rand int      rv;
    int r; int i;
    function int g(int a, int b = $bits(pk4[0] & 8'h0F)); return a + b; endfunction
    constraint cc { rv < $bits(pk4[0] & 8'h0F); }         // e01 constraint
    function void m();
      case ($bits(dyn[i] & be))                            // e02 case expr
        8: r = 1;
        default: r = 2;
      endcase
      case (r)
        $bits(pk4[i] & be): r = 3;                         // e03 case item
        default: r = 4;
      endcase
      r = g($bits(dyn[i] & be));                           // e04 call arg positional
      r = g(.a($bits(dyn[i] & be)), .b(1));                // e05 named arg
      r = dyn[$bits(pk4[i] & be) % 4];                     // e06 index
      r = {$bits(dyn[i] & be)};                            // e07 concat operand
      r = (i ? $bits(dyn[i] & be) : 0);                    // e08 ternary operand
      if ($bits(dyn[i] & be) > 4) r = 5;                   // e09 if cond
      while (r < $bits(dyn[i] & be)) r++;                  // e10 loop cond
      for (int k = 0; k < $bits(pk4[i] & be); k++) r++;    // e11 for cond
      repeat ($bits(dyn[i] & be)) r++;                     // e12 repeat
      $display("%0d", $bits(dyn[i] & be));                 // e13 sys arg
      r = g(1, $bits(dyn[i] & be));                        // e14
      $display("%0d", r);
    endfunction
  endclass
endpackage
module sub #(parameter int P = 8) (input logic [P-1:0] pin, output logic [7:0] po);
  assign po = pin[7:0];
endmodule
module vD;
  import pD2::*;
  logic [7:0] mpk4 [4];
  byte unsigned mbe;
  logic [7:0] o1, o2;
  logic [31:0] busx;
  int mi, mr;
  wire [63:0] wq;
  localparam int LPD = $bits(mpk4[1] & 8'h0F);
  sub #(.P($bits(mpk4[1] & 8'h0F))) u1 (.pin(busx[7:0]), .po(o1));   // e15 param actual
  sub #(8) u2 (.pin(busx[7:0]), .po(o2));                        // e16
  assign wq[$bits(mpk4[1] & 8'h0F)/8 : 0] = 32'd1;              // e17 part-select bound
  initial begin
    CD c = new(); c.m();
    mr = LPD;
    $display("%0d %0d %0d", mr, o1, o2);
  end
endmodule
