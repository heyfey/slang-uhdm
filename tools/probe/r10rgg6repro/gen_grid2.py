#!/usr/bin/env python3
"""r10rgg6/gen_grid2.py -- round 2.  Round 1 separated the cells cleanly on ONE
axis (`third`), so round 2 tests the MECHANISM that axis implies:

  the formal-typespec write-through reaches the TREE object only for a call
  that is evaluated NESTED inside another function evaluation; the OUTERMOST
  evaluated call's own argument binding reaches evalFunc's *cloned* copy of the
  enclosing scope's param_assigns and never touches the tree.

Falsifiable predictions:
  P-1  chain of four (P4 = h(P3), P3 = g(P2), P2 = f(P1), P1 = f1(N)), P4
       demanded: P3's call bare, P2's call stamped with g's formal, P1's call
       stamped with f's formal.
  P-2  nothing demands P3 -> no stamp anywhere.
  P-3  Rggen's shape PLUS one extra consumer of P2 -> P1's call stamped after
       all.
  P-4  two consumers of P1 with DIFFERENT formal typespecs, both nested ->
       which typespec ends up on P1's call (first? last?).
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

  function automatic int f3(bit [N-1:0][15:0] a3);
    int next_n;
    next_n = 0;
    for (int i = 0;i < N;++i) next_n += ((a3[i] != 0) ? 1 : 0);
    return next_n;
  endfunction

  function automatic int h1(bit [15:0] narrow_v);
    return int'(narrow_v) + 1;
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
# P-1: chain of four, only P4 demanded
'r2_chain4': ("""
  localparam  bit [N-1:0][15:0] P1 = f1(N);
  localparam  bit [N-1:0][15:0] P2 = f2(P1);
  localparam  bit [N-1:0][15:0] P3 = g2(P2);
  localparam  int               P4 = f3(P3);
""", 'P4'),
# P-1 control: chain of three, only P3 demanded  (== round-1 top_p2)
'r2_chain3': ("""
  localparam  bit [N-1:0][15:0] P1 = f1(N);
  localparam  bit [N-1:0][15:0] P2 = f2(P1);
  localparam  int               P3 = f3(P2);
""", 'P3'),
# P-2: chain of three, NOTHING demands P3
'r2_chain3_nodemand': ("""
  localparam  bit [N-1:0][15:0] P1 = f1(N);
  localparam  bit [N-1:0][15:0] P2 = f2(P1);
  localparam  int               P3 = f3(P2);
""", '2'),
# Rggen's shape: two DIRECT consumers of P1, neither nested
'r2_rggen': ("""
  localparam  bit [N-1:0][15:0] P1 = f1(N);
  localparam  bit [N-1:0][15:0] P2 = f2(P1);
  localparam  int               P3 = f3(P1);
""", 'P3'),
# P-3: Rggen's shape PLUS a nested consumer of P2
'r2_rggen_plus': ("""
  localparam  bit [N-1:0][15:0] P1 = f1(N);
  localparam  bit [N-1:0][15:0] P2 = f2(P1);
  localparam  int               P3 = f3(P1);
  localparam  int               P4 = f3(P2);
""", 'P4'),
# P-4: two consumers of P1 with different formal typespecs, f2 FIRST
'r2_two_ts_f2first': ("""
  localparam  bit [N-1:0][15:0] P1 = f1(N);
  localparam  bit [N-1:0][15:0] P2 = f2(P1);
  localparam  bit [N-1:0][15:0] P2B = g2(P1);
  localparam  int               P3 = f3(P2);
  localparam  int               P3B = f3(P2B);
""", 'P3'),
# P-4 mirror: g2 FIRST
'r2_two_ts_g2first': ("""
  localparam  bit [N-1:0][15:0] P1 = f1(N);
  localparam  bit [N-1:0][15:0] P2B = g2(P1);
  localparam  bit [N-1:0][15:0] P2 = f2(P1);
  localparam  int               P3B = f3(P2B);
  localparam  int               P3 = f3(P2);
""", 'P3'),
# demand through a DIFFERENT kind of consumer: a net range, not a param
'r2_demand_net': ("""
  localparam  bit [N-1:0][15:0] P1 = f1(N);
  localparam  bit [N-1:0][15:0] P2 = f2(P1);
  logic [f3(P2)-1:0] wnet;
""", '2'),
# the nested call is a SYSTEM-free depth-2 chain but the outer one is a
# cont-assign, not a param initializer
'r2_ca_outer': ("""
  localparam  bit [N-1:0][15:0] P1 = f1(N);
  localparam  bit [N-1:0][15:0] P2 = f2(P1);
  wire [31:0] w3;
  assign w3 = f3(P2);
""", '2'),
# depth-2 where the inner formal is NARROW (h1 takes bit[15:0]) -- does the
# stamp follow the formal even when it does not match P1's own type?
'r2_narrow_inner': ("""
  localparam  bit [15:0]        PN = 16'd3;
  localparam  bit [N-1:0][15:0] P1 = f1(N);
  localparam  int               PH = h1(PN);
  localparam  bit [N-1:0][15:0] P2 = f2(P1);
  localparam  int               P3 = f3(P2);
""", 'P3'),
}

def main():
    for name, (params, width) in CELLS.items():
        d = os.path.join(ROOT, 'cells', name)
        os.makedirs(d, exist_ok=True)
        with open(os.path.join(d, 'dut.sv'), 'wt') as f:
            f.write(HDR + params + TAIL % (width, width))
    print(len(CELLS), 'round-2 cells')

if __name__ == '__main__':
    main()
