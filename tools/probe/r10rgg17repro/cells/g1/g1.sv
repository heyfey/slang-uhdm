// r10rgg17 grid g1 — the HIER_PATH PORT ACTUAL over an INTERFACE ARRAY element.
// One instantiation per index shape, all inside a gen-for whose genvar is the
// block's own; the tail is the trailing indexed part-select the head carries.
interface sif;
  logic [31:0] value;
  logic [31:0] other;
endinterface

module sink (input logic [3:0] d);
endmodule
module sink1 (input logic d);
endmodule
module sink32 (input logic [31:0] d);
endmodule

module top;
  localparam int LP = 3;
  parameter  int P  = 2;
  sif arr[20]();

  for (genvar i = 0; i < 2; i++) begin : g
    // A1 bare genvar index, indexed part-select tail with a genvar base
    sink u_a1 (.d(arr[i].value[0+1*i+:4]));
    // A2 arithmetic index (add only)
    sink u_a2 (.d(arr[3+i].value[0+:4]));
    // A3 arithmetic index with a MULT on the spine (the head's shape)
    sink u_a3 (.d(arr[6+7*i+6].value[0+1*i+:4]));
    // A4 parameter + genvar index
    sink u_a4 (.d(arr[P+i].value[0+:4]));
    // A5 BARE parameter index (rgg14's abstain, R-B)
    sink u_a5 (.d(arr[P].value[0+:4]));
    // A6 BARE localparam index
    sink u_a6 (.d(arr[LP].value[0+:4]));
    // A7 literal index
    sink u_a7 (.d(arr[7].value[0+:4]));
    // A8 plain member tail (no select)
    sink32 u_a8 (.d(arr[2+3*i].value));
    // A9 bit-select tail
    sink1 u_a9 (.d(arr[2+3*i].value[3]));
    // A10 simple range tail
    sink u_a10 (.d(arr[2+3*i].value[3:0]));
    // A11 descending indexed part-select tail
    sink u_a11 (.d(arr[2+3*i].value[3-:4]));
  end
endmodule
