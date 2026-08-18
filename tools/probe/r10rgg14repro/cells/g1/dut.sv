interface sif #(
  parameter int W = 1
);
  logic [W-1:0] v;
  modport mp (input v);
endinterface

module leaf (
  sif.mp s
);
  wire w;
  assign w = s.v[0];
endmodule

module top #(
  parameter int P = 5
);
  sif #(1) arr [0:63] ();
  genvar i, j;
  for (i = 0; i < 2; ++i) begin : g
    leaf ua (.s (arr[i]));
    leaf ub (.s (arr[3+i]));
    leaf uc (.s (arr[2+4*i]));
    leaf ud (.s (arr[i*2+1]));
    leaf ue (.s (arr[P+i]));
    leaf uf (.s (arr[P]));
    leaf ug (.s (arr[7]));
    leaf uh (.s (arr[2+4*i+6]));
    for (j = 0; j < 2; ++j) begin : h
      leaf uj (.s (arr[1+2*i+j]));
      leaf uk (.s (arr[i+j]));
    end
  end
endmodule
