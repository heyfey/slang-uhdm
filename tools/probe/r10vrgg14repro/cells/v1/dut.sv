// v1 — interface-array port actual, expression ZOO (the ModuleEmit site).
interface sif;
  logic v;
  modport mp (input v);
endinterface
module ileaf (sif.mp s);
  wire w; assign w = s.v;
endmodule
module top #(parameter int P = 5, parameter int Q = 3);
  sif arr [0:63] ();
  genvar i, j;
  for (i = 0; i < 2; ++i) begin : g
    ileaf a00 (.s (arr[i]));
    ileaf a01 (.s (arr[i+1]));
    ileaf a02 (.s (arr[1+i]));
    ileaf a03 (.s (arr[3*i+2]));
    ileaf a04 (.s (arr[2+3*i]));
    ileaf a05 (.s (arr[i-0]));
    ileaf a06 (.s (arr[8-i]));
    ileaf a07 (.s (arr[(i+1)]));
    ileaf a08 (.s (arr[i*2]));
    ileaf a09 (.s (arr[2*i]));
    ileaf a10 (.s (arr[i/1]));
    ileaf a11 (.s (arr[i%2]));
    ileaf a12 (.s (arr[i<<1]));
    ileaf a13 (.s (arr[i>>1]));
    ileaf a14 (.s (arr[i&1]));
    ileaf a15 (.s (arr[i|8]));
    ileaf a16 (.s (arr[i^4]));
    ileaf a17 (.s (arr[P+i]));
    ileaf a18 (.s (arr[i+P]));
    ileaf a19 (.s (arr[P*i]));
    ileaf a20 (.s (arr[i*P]));
    ileaf a21 (.s (arr[P]));
    ileaf a22 (.s (arr[7]));
    ileaf a23 (.s (arr[P+Q]));
    ileaf a24 (.s (arr[i ? 3 : 4]));
    ileaf a25 (.s (arr[2**i]));
    ileaf a26 (.s (arr[3'd2+i]));
    ileaf a27 (.s (arr[3'h2+i]));
    ileaf a28 (.s (arr[3'b010+i]));
    ileaf a29 (.s (arr[-(-i)]));
    ileaf a30 (.s (arr[i+2+3]));
    ileaf a31 (.s (arr[(2+3)*i]));
    for (j = 0; j < 2; ++j) begin : h
      ileaf b00 (.s (arr[i+j]));
      ileaf b01 (.s (arr[1+2*i+j]));
      ileaf b02 (.s (arr[i*4+j*2+1]));
      ileaf b03 (.s (arr[j]));
    end
  end
endmodule
