// v99 b1 — inside-set shapes, all in if-conditions, module scope
package pk99b1;
  localparam int LOB1 = 3;
  localparam int HIB1 = 9;
  typedef enum int { EA1 = 1, EB1 = 4, EC1 = 7 } en_b1;
endpackage

module topb1 (input logic clk_b1);
  import pk99b1::*;
  int    zz1, yy2, ww3;
  int    qq4 [$];
  int    dd5 [];
  int    aa6 [4];
  string ss7;
  en_b1  ee8;
  logic [7:0] nb9;
  int r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18;

  always @(*) begin
    // 1 single plain value only (no range) -- FENCE
    if (zz1 inside {7})                       r1 = 1;
    // 2 plain list, no range -- FENCE
    if (yy2 inside {2, 5, 8})                 r2 = 2;
    // 3 single simple range
    if (ww3 inside {[3:9]})                   r3 = 3;
    // 4 range FIRST, plain after
    if (zz1 inside {[3:9], 11, 13})           r4 = 4;
    // 5 plain FIRST, range after
    if (yy2 inside {11, [3:9], 13})           r5 = 5;
    // 6 two ranges
    if (ww3 inside {[3:9], [20:30]})          r6 = 6;
    // 7 localparam bounds
    if (zz1 inside {[LOB1:HIB1]})             r7 = 7;
    // 8 enum bounds
    if (ee8 inside {[EA1:EC1]})               r8 = 8;
    // 9 unbounded upper
    if (yy2 inside {[4:$]})                   r9 = 9;
    // 10 unbounded lower
    if (ww3 inside {[$:6]})                   r10 = 10;
    // 11 negative bounds
    if (zz1 inside {[-9:-2]})                 r11 = 11;
    // 12 string members with a string range
    if (ss7 inside {"aa", ["bb":"dd"]})       r12 = 12;
    // 13 unpacked array member first, range after
    if (zz1 inside {aa6, [3:9]})              r13 = 13;
    // 14 queue member first, range after
    if (yy2 inside {qq4, [3:9]})              r14 = 14;
    // 15 element-select first bound
    if (ww3 inside {[aa6[1]:aa6[2]]})         r15 = 15;
    // 16 parenthesised first bound
    if (zz1 inside {[(LOB1):HIB1]})           r16 = 16;
    // 17 compound first bound (R1 splice shape)
    if (yy2 inside {[LOB1+1:HIB1]})           r17 = 17;
    // 18 narrow LHS, int bounds (implicit conversion candidate)
    if (nb9 inside {[LOB1:HIB1]})             r18 = 18;
  end
endmodule
