#!/usr/bin/env python3
"""r10rgg6/gen_grid3.py -- round 3.  Round 2 fixed the law's SHAPE; round 3
fixes the two things an implementation still has to choose:

  * ORDER.  "Last wins" -- but last in WHICH order?  r2_two_ts_* cannot tell,
    because their inner (consumer) order and their outer (driving) order agree.
    r3_order_split makes them DISAGREE.
  * REACH.  Which OUTER sites drive a nested evaluation at all: a declaration
    range (r2_demand_net said yes), an inline nested call, a procedural call,
    an unpacked dimension, a generate condition.
  * DEPTH.  A five-deep chain, to see the recursion bottom out or not.
"""
import os
ROOT = os.path.dirname(os.path.abspath(__file__))

HDR = """module m #(
  parameter int WIDTH = 2,
  parameter int N = 4
)(
  input   logic [N-1:0][WIDTH-1:0]  i_data,
  output  logic [WIDTH-1:0]         o_result
);
  function automatic bit [N-1:0][15:0] f1(int n);
    bit [N-1:0][15:0] list;
    int               list_index;
    bit [15:0]        current_n;
    bit [15:0]        half_n;

    list        = '0;
    list_index  = 0;
    current_n   = 16'(n);
    while (current_n > 0) begin
      half_n  = current_n / 2;
      if ((current_n > 4) && (half_n <= 4)) begin
        list[list_index]  = half_n;
      end
      else if (current_n >= 4) begin
        list[list_index]  = 4;
      end
      else begin
        list[list_index]  = current_n;
      end

      current_n   -= list[list_index];
      list_index  += 1;
    end

    return list;
  endfunction

  function automatic bit [N-1:0][15:0] f2(bit [N-1:0][15:0] a2);
    bit [N-1:0][15:0] list;
    for (int i = 0;i < N;++i) list[i] = a2[i] + 16'(i);
    return list;
  endfunction

  function automatic bit [N-1:0][15:0] g2(bit [N-1:0][15:0] b2);
    bit [N-1:0][15:0] list;
    for (int i = 0;i < N;++i) list[i] = b2[i] + 16'd7;
    return list;
  endfunction

  function automatic bit [N-1:0][15:0] k2(bit [N-1:0][15:0] c2, bit [N-1:0][15:0] d2);
    bit [N-1:0][15:0] list;
    for (int i = 0;i < N;++i) list[i] = c2[i] + d2[i];
    return list;
  endfunction

  function automatic int f3(bit [N-1:0][15:0] a3);
    int next_n;
    next_n = 0;
    for (int i = 0;i < N;++i) next_n += ((a3[i] != 0) ? 1 : 0);
    return next_n;
  endfunction
"""

TAIL = """
  logic [%s-1:0][WIDTH-1:0] next_data;

  always_comb begin
    for (int i = 0;i < %s;++i) begin
      next_data[i]  = i_data[0];
    end
  end

  always_comb begin
    o_result = next_data[0];
  end
endmodule
"""

CELLS = {
# ORDER: inner order says f2 last, outer order says g2 last.
'r3_order_split': ("""
  localparam  bit [N-1:0][15:0] P1  = f1(N);
  localparam  bit [N-1:0][15:0] P2B = g2(P1);
  localparam  bit [N-1:0][15:0] P2  = f2(P1);
  localparam  int               P3  = f3(P2);
  localparam  int               P3B = f3(P2B);
""", 'P3'),
# REACH: outer call inline-nested inside the SAME initializer
'r3_inline_nested': ("""
  localparam  bit [N-1:0][15:0] P1 = f1(N);
  localparam  int               P3 = f3(f2(P1));
""", 'P3'),
# REACH: outer call in a PROCEDURAL statement
'r3_proc_outer': ("""
  localparam  bit [N-1:0][15:0] P1 = f1(N);
  localparam  bit [N-1:0][15:0] P2 = f2(P1);
  int r3;
  always_comb begin
    r3 = f3(P2);
  end
""", '2'),
# REACH: outer call in an UNPACKED dimension
'r3_unpacked_dim': ("""
  localparam  bit [N-1:0][15:0] P1 = f1(N);
  localparam  bit [N-1:0][15:0] P2 = f2(P1);
  logic [1:0] arr [f3(P2)];
""", '2'),
# REACH: outer call in a GENERATE condition
'r3_gen_cond': ("""
  localparam  bit [N-1:0][15:0] P1 = f1(N);
  localparam  bit [N-1:0][15:0] P2 = f2(P1);
  generate
    if (f3(P2) > 1) begin : gy
      wire tie1;
      assign tie1 = 1'b1;
    end
  endgenerate
""", '2'),
# DEPTH: five-deep chain
'r3_chain5': ("""
  localparam  bit [N-1:0][15:0] P1 = f1(N);
  localparam  bit [N-1:0][15:0] P2 = f2(P1);
  localparam  bit [N-1:0][15:0] P3 = g2(P2);
  localparam  bit [N-1:0][15:0] P4 = f2(P3);
  localparam  int               P5 = f3(P4);
""", 'P5'),
# TWO param actuals on one nested call, both with func_call Rhs
'r3_two_actuals': ("""
  localparam  bit [N-1:0][15:0] P1  = f1(N);
  localparam  bit [N-1:0][15:0] P1B = g2(P1);
  localparam  bit [N-1:0][15:0] P2  = k2(P1, P1B);
  localparam  int               P3  = f3(P2);
""", 'P3'),
# the nested consumer's actual is the param used TWICE in one call
'r3_same_twice': ("""
  localparam  bit [N-1:0][15:0] P1 = f1(N);
  localparam  bit [N-1:0][15:0] P2 = k2(P1, P1);
  localparam  int               P3 = f3(P2);
""", 'P3'),
}

def main():
    for name, (params, width) in CELLS.items():
        d = os.path.join(ROOT, 'cells', name)
        os.makedirs(d, exist_ok=True)
        with open(os.path.join(d, 'dut.sv'), 'wt') as f:
            f.write(HDR + params + TAIL % (width, width))
    print(len(CELLS), 'round-3 cells')

if __name__ == '__main__':
    main()
